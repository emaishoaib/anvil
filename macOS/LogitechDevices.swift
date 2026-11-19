import AppKit
import IOKit.hid
import MouseKit
import Observation
import os

@MainActor @Observable final class LogitechDevices {
    static let shared = LogitechDevices()

    private static let matching: [[String: Int]] = [
        [kIOHIDVendorIDKey: HIDPPRequest.logitechVendorID, kIOHIDDeviceUsagePageKey: 0xFF00, kIOHIDDeviceUsageKey: 0x02],
        [kIOHIDVendorIDKey: HIDPPRequest.logitechVendorID, kIOHIDDeviceUsagePageKey: 0xFF43, kIOHIDDeviceUsageKey: 0x0202],
    ]
    private static let discoveryPauses: [Duration] = [.zero, .seconds(1), .seconds(2), .seconds(4)]
    private static let quickRecheckPause = Duration.milliseconds(500)
    private static let quickRecheckCount = 10
    private static let finalRecheckPause = Duration.seconds(8)
    private static let recheckPauses: [Duration] = [.zero] + Array(repeating: quickRecheckPause, count: quickRecheckCount) + [finalRecheckPause]

    private(set) var devices: [LogitechDevice] = []
    private(set) var batteries: [String: BatteryStatus] = [:]
    private(set) var dpis: [String: SensorDPI] = [:]
    private var busyTasks = 0
    @ObservationIgnored private var channels: [HIDPPChannel] = []
    @ObservationIgnored private var heldGestureButtons: Set<String> = []
    @ObservationIgnored private let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

    /// Whether Anvil is finding devices or sending their settings right now.
    var isBusy: Bool { busyTasks > 0 }

    func start() {
        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerSetDeviceMatchingMultiple(manager, Self.matching as CFArray)
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, device in
            guard let context else { return }
            let devices = Unmanaged<LogitechDevices>.fromOpaque(context).takeUnretainedValue()
            MainActor.assumeIsolated { devices.added(device) }
        }, context)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, device in
            guard let context else { return }
            let devices = Unmanaged<LogitechDevices>.fromOpaque(context).takeUnretainedValue()
            MainActor.assumeIsolated { devices.removed(device) }
        }, context)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated {
                Logger.logitech.notice("The Mac woke, so looking for devices again")
                LogitechDevices.shared.rediscover()
            }
        }
    }

    /// Looks again for the devices on every channel, as after the Mac wakes, when they may still be reconnecting and have forgotten their settings.
    private func rediscover() {
        for channel in channels {
            whileBusy { await self.discover(on: channel) }
        }
    }

    func applyMouseTool() {
        Logger.logitech.notice("Sending the mouse settings to every known device again")
        for channel in channels {
            let onChannel = devices.filter { $0.id.hasPrefix(channel.id) }
            whileBusy { for device in onChannel { await self.applyMouseTool(to: device, on: channel) } }
        }
    }

    /// Runs device work in the background, and counts Anvil as busy until it finishes.
    private func whileBusy(_ work: @escaping @MainActor () async -> Void) {
        if busyTasks == 0 { Logger.logitech.info("Busy") }
        busyTasks += 1
        Task {
            await work()
            busyTasks -= 1
            if busyTasks == 0 { Logger.logitech.info("No longer busy") }
        }
    }

    private func applyMouseTool(to device: LogitechDevice, on channel: HIDPPChannel) async {
        await GestureButton.apply(to: device, on: channel)
        await WheelResolution.shared.apply(to: device, on: channel)
        await WheelRatchet.apply(to: device, on: channel)
        await ThumbWheel.shared.apply(to: device, on: channel)
        dpis[device.id] = await MouseDPI.shared.apply(to: device, on: channel)
        Logger.logitech.notice("Sent the mouse settings to \(device.name, privacy: .public) on channel \(channel.logName, privacy: .public)")
    }

    private func added(_ device: IOHIDDevice) {
        let channel = HIDPPChannel(device: device)
        Logger.logitech.notice("Channel \(channel.logName, privacy: .public) appeared: \(channel.logDevice, privacy: .public)")
        channel.onNotification = { [weak self, weak channel] report in
            guard let self, let channel else { return }
            notified(report, on: channel)
        }
        channels.append(channel)
        whileBusy { await self.discover(on: channel) }
    }

    /// Looks for devices on a channel, and tries again a few times when none answers yet, as when a mouse has only just reconnected.
    private func discover(on channel: HIDPPChannel) async {
        for (attempt, pause) in Self.discoveryPauses.enumerated() {
            try? await Task.sleep(for: pause)
            guard channels.contains(where: { $0 === channel }) else { return }
            Logger.logitech.notice("Looking for devices on channel \(channel.logName, privacy: .public), try \(attempt + 1) of \(Self.discoveryPauses.count)")
            let found = await LogitechDiscovery.devices(on: channel)
            let names = found.map(\.name).joined(separator: ", ")
            Logger.logitech.notice("Channel \(channel.logName, privacy: .public) found \(found.isEmpty ? "no devices" : names, privacy: .public)")
            guard found.isEmpty else {
                for device in found { await use(device, on: channel) }
                return
            }
        }
    }

    private func removed(_ device: IOHIDDevice) {
        let gone = channels.filter { CFEqual($0.device, device) }
        for channel in gone { Logger.logitech.notice("Channel \(channel.logName, privacy: .public) disappeared") }
        gone.forEach { $0.stop() }
        channels.removeAll { CFEqual($0.device, device) }
        devices.removeAll { found in gone.contains { found.id.hasPrefix($0.id) } }
        batteries = batteries.filter { id, _ in devices.contains { $0.id == id } }
        dpis = dpis.filter { id, _ in devices.contains { $0.id == id } }
    }

    private func use(_ device: LogitechDevice, on channel: HIDPPChannel) async {
        guard channels.contains(where: { $0 === channel }) else { return }
        devices.removeAll { $0.id == device.id }
        devices.append(device)
        await readBattery(of: device, on: channel)
        await applyMouseTool(to: device, on: channel)
        Task { await keepApplied(to: device, on: channel) }
    }

    /// Reads the gesture button and the ratchet again after a device is set up, every half second for the first five seconds and once more at thirteen, and sets them again whenever the mouse has gone back to its own defaults. The MX Master 3S does that within a few seconds of connecting, so the quick checks keep the button working and the wheel ratcheting within half a second.
    private func keepApplied(to device: LogitechDevice, on channel: HIDPPChannel) async {
        var waited = Duration.zero
        for pause in Self.recheckPauses {
            try? await Task.sleep(for: pause)
            waited += pause
            let seconds = String(format: "%.1f", waited / .seconds(1))
            Logger.logitech.info("Checking the gesture button and ratchet on \(device.name, privacy: .public) again, \(seconds, privacy: .public) s after setting it up")
            await GestureButton.apply(to: device, on: channel)
            await WheelRatchet.apply(to: device, on: channel)
        }
    }

    private func readBattery(of device: LogitechDevice, on channel: HIDPPChannel) async {
        guard let batteryFeature = device.batteryFeature,
              let parameters = await channel.send(.batteryStatus(of: device.deviceIndex, batteryFeature: batteryFeature))?.parameters
        else { return }
        batteries[device.id] = BatteryStatus(parameters: parameters)
    }

    private func notified(_ report: [UInt8], on channel: HIDPPChannel) {
        guard report.count > 1 else { return }
        let index = channel.isBluetooth ? HIDPPRequest.directDeviceIndex : report[1]
        let id = LogitechDevice.id(channel: channel.id, deviceIndex: index)
        let known = devices.first { $0.id == id }
        switch HIDPPNotification(
            report: report,
            from: index,
            controlsFeature: known?.controlsFeature,
            wirelessStatusFeature: known?.wirelessStatusFeature,
            batteryFeature: known?.batteryFeature,
            thumbWheelFeature: known?.thumbWheelFeature
        ) {
        case .controlsHeld(let held):
            let isDown = held.contains(HIDPPRequest.buttonBehindWheelControl)
            guard isDown != heldGestureButtons.contains(id) else { return }
            if isDown { heldGestureButtons.insert(id) } else { heldGestureButtons.remove(id) }
            GestureButton.send(isDown: isDown)
        case .linkRestored:
            Logger.logitech.notice("Device \(index) reconnected on channel \(channel.logName, privacy: .public)")
            whileBusy { if let device = await LogitechDiscovery.device(at: index, on: channel) { await self.use(device, on: channel) } }
        case .batteryChanged(let status):
            batteries[id] = status
        case .thumbWheelTurned(let rotation):
            ThumbWheelScroller.scroll(rotation)
        case nil:
            return
        }
    }
}
