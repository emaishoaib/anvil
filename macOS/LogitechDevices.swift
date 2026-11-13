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
    @ObservationIgnored private var channels: [HIDPPChannel] = []
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
    }

    private func added(_ device: IOHIDDevice) {
        let channel = HIDPPChannel(device: device)
        channels.append(channel)
        Task {
            let found = await Self.discover(on: channel)
            guard channels.contains(where: { $0 === channel }) else { return }
            devices += found
        }
    }

    private func removed(_ device: IOHIDDevice) {
        let gone = channels.filter { CFEqual($0.device, device) }
        gone.forEach { $0.stop() }
        channels.removeAll { CFEqual($0.device, device) }
        devices.removeAll { found in gone.contains { found.id.hasPrefix($0.id) } }
    }

    private static func discover(on channel: HIDPPChannel) async -> [LogitechDevice] {
        if let direct = await device(at: HIDPPRequest.directDeviceIndex, on: channel) { return [direct] }
        var found: [LogitechDevice] = []
        for slot in HIDPPRequest.receiverSlots {
            if let device = await device(at: slot, on: channel) { found.append(device) }
        }
        return found
    }

    private static func device(at index: UInt8, on channel: HIDPPChannel) async -> LogitechDevice? {
        guard let version = await channel.send(.protocolVersion(of: index))?.parameters, version.first ?? 0 >= 2,
              let nameFeature = await channel.send(.featureIndex(of: HIDPPRequest.deviceNameFeature, on: index))?.parameters?.first,
              nameFeature != 0,
              let length = await channel.send(.nameLength(of: index, nameFeature: nameFeature))?.parameters?.first
        else { return nil }
        var parts: [[UInt8]] = []
        while parts.map(\.count).reduce(0, +) < Int(length),
              let part = await channel.send(.namePart(of: index, nameFeature: nameFeature, from: parts.map(\.count).reduce(0, +)))?.parameters {
            parts.append(part)
        }
        let kind = await channel.send(.kind(of: index, nameFeature: nameFeature))?.parameters?.first.flatMap(LogitechDeviceKind.init(rawValue:))
        return LogitechDevice(channel: channel.id, name: LogitechDevice.name(from: parts, length: Int(length)), kind: kind, deviceIndex: index)
    }
}
