import MouseKit

/// Keeps the MX Master wheel in ratchet mode with the ratchet always engaged while the mouse tool and its setting are on, and puts back the mouse's own SmartShift otherwise.
final class WheelRatchet {
    static let shared = WheelRatchet()

    private var originals: [String: SmartShift] = [:]

    func apply(to device: LogitechDevice, on channel: HIDPPChannel) async {
        guard device.kind == .mouse, let feature = device.smartShiftFeature else { return }
        if Tool.mouse.isOn && MouseSettingsLibrary.current.ratchetAlwaysEngaged {
            await alwaysEngage(device, feature: feature, on: channel)
        } else {
            await restore(device, feature: feature, on: channel)
        }
    }

    private func alwaysEngage(_ device: LogitechDevice, feature: SmartShiftFeature, on channel: HIDPPChannel) async {
        guard let parameters = await channel.send(.smartShift(of: device.deviceIndex, feature: feature))?.parameters,
              let current = SmartShift(parameters: parameters),
              current != .ratchetAlwaysEngaged
        else { return }
        originals[device.id] = current
        _ = await channel.send(.setSmartShift(.ratchetAlwaysEngaged, of: device.deviceIndex, feature: feature))
    }

    private func restore(_ device: LogitechDevice, feature: SmartShiftFeature, on channel: HIDPPChannel) async {
        guard let original = originals.removeValue(forKey: device.id) else { return }
        _ = await channel.send(.setSmartShift(original, of: device.deviceIndex, feature: feature))
    }
}
