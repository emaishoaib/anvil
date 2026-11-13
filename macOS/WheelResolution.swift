import MouseKit

final class WheelResolution {
    static let shared = WheelResolution()

    private var originalModes: [String: WheelMode] = [:]

    func apply(to device: LogitechDevice, on channel: HIDPPChannel) async {
        guard device.kind == .mouse, let wheelFeature = device.wheelFeature else { return }
        if Tool.mouse.isOn {
            await reportOncePerNotch(device, wheelFeature: wheelFeature, on: channel)
        } else {
            await restore(device, wheelFeature: wheelFeature, on: channel)
        }
    }

    private func reportOncePerNotch(_ device: LogitechDevice, wheelFeature: UInt8, on channel: HIDPPChannel) async {
        guard let byte = await channel.send(.wheelMode(of: device.deviceIndex, wheelFeature: wheelFeature))?.parameters?.first else { return }
        let mode = WheelMode(rawValue: byte)
        guard mode.contains(.highResolution) else { return }
        originalModes[device.id] = mode
        _ = await channel.send(.setWheelMode(mode.oneReportPerNotch, of: device.deviceIndex, wheelFeature: wheelFeature))
    }

    private func restore(_ device: LogitechDevice, wheelFeature: UInt8, on channel: HIDPPChannel) async {
        guard let original = originalModes.removeValue(forKey: device.id) else { return }
        _ = await channel.send(.setWheelMode(original, of: device.deviceIndex, wheelFeature: wheelFeature))
    }
}
