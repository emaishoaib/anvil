import MouseKit

/// Keeps the MX Master wheel in ratchet mode, disengaging at the speed chosen in the mouse settings, while the mouse tool is on. At the top speed the ratchet never disengages. Otherwise the ratchet disengages on a fast flick, at the mouse's own default speed.
enum WheelRatchet {
    static func apply(to device: LogitechDevice, on channel: HIDPPChannel) async {
        guard device.kind == .mouse, let feature = device.smartShiftFeature,
              let parameters = await channel.send(.smartShift(of: device.deviceIndex, feature: feature))?.parameters
        else { return }
        let wanted: SmartShift? = if Tool.mouse.isOn {
            .ratchet(disengagingAt: MouseSettingsLibrary.current.ratchetDisengageSpeed)
        } else {
            .ratchetDisengagingAtDefaultSpeed(from: parameters)
        }
        guard let wanted, wanted != SmartShift(parameters: parameters) else { return }
        _ = await channel.send(.setSmartShift(wanted, of: device.deviceIndex, feature: feature))
    }
}
