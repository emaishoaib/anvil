import AppKit
import IOKit.hid
import MouseKit
import Observation

@MainActor @Observable final class LogitechDevices {
    static let shared = LogitechDevices()

    private static let matching: [[String: Int]] = [
        [kIOHIDVendorIDKey: HIDPPRequest.logitechVendorID, kIOHIDDeviceUsagePageKey: 0xFF00, kIOHIDDeviceUsageKey: 0x02],
        [kIOHIDVendorIDKey: HIDPPRequest.logitechVendorID, kIOHIDDeviceUsagePageKey: 0xFF43, kIOHIDDeviceUsageKey: 0x0202],
    ]

    private(set) var devices: [LogitechDevice] = []
    private(set) var batteries: [String: BatteryStatus] = [:]
    private(set) var dpis: [String: SensorDPI] = [:]
    @ObservationIgnored private var channels: [HIDPPChannel] = []
    @ObservationIgnored private var heldGestureButtons: Set<String> = []
    @ObservationIgnored private let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

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
            MainActor.assumeIsolated { LogitechDevices.shared.applyMouseTool() }
        }
    }

    func applyMouseTool() {
        for channel in channels {
            let onChannel = devices.filter { $0.id.hasPrefix(channel.id) }
            Task { for device in onChannel { await applyMouseTool(to: device, on: channel) } }
        }
    }

    private func applyMouseTool(to device: LogitechDevice, on channel: HIDPPChannel) async {
        await GestureButton.takeOver(device, on: channel)
        await WheelResolution.shared.apply(to: device, on: channel)
        await WheelRatchet.apply(to: device, on: channel)
        dpis[device.id] = await MouseDPI.shared.apply(to: device, on: channel)
    }

    private func added(_ device: IOHIDDevice) {
        let channel = HIDPPChannel(device: device)
        channel.onNotification = { [weak self, weak channel] report in
            guard let self, let channel else { return }
            notified(report, on: channel)
        }
        channels.append(channel)
        Task {
            for device in await LogitechDiscovery.devices(on: channel) { await use(device, on: channel) }
        }
    }

    private func removed(_ device: IOHIDDevice) {
        let gone = channels.filter { CFEqual($0.device, device) }
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
    }

    private func readBattery(of device: LogitechDevice, on channel: HIDPPChannel) async {
        guard let batteryFeature = device.batteryFeature,
              let parameters = await channel.send(.batteryStatus(of: device.deviceIndex, batteryFeature: batteryFeature))?.parameters
        else { return }
        batteries[device.id] = BatteryStatus(parameters: parameters)
    }

    private func notified(_ report: [UInt8], on channel: HIDPPChannel) {
        guard report.count > 1 else { return }
        let index = report[1]
        let id = LogitechDevice.id(channel: channel.id, deviceIndex: index)
        let known = devices.first { $0.id == id }
        switch HIDPPNotification(
            report: report,
            from: index,
            controlsFeature: known?.controlsFeature,
            wirelessStatusFeature: known?.wirelessStatusFeature,
            batteryFeature: known?.batteryFeature
        ) {
        case .controlsHeld(let held):
            let isDown = held.contains(HIDPPRequest.buttonBehindWheelControl)
            guard isDown != heldGestureButtons.contains(id) else { return }
            if isDown { heldGestureButtons.insert(id) } else { heldGestureButtons.remove(id) }
            GestureButton.send(isDown: isDown)
        case .linkRestored:
            Task { if let device = await LogitechDiscovery.device(at: index, on: channel) { await use(device, on: channel) } }
        case .batteryChanged(let status):
            batteries[id] = status
        case nil:
            return
        }
    }
}
