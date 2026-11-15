import MouseKit

/// Takes a Logitech mouse's thumb wheel over while the mouse tool is on, so its turns reach Anvil as HID++ messages instead of as sideways scrolling, and hands it back when the tool is off. The direction the mouse itself had is kept and set again on hand back. A thumb wheel found already diverted is taken to have been left that way by Anvil, so it is handed back undiverted.
final class ThumbWheel {
    static let shared = ThumbWheel()

    private static let divertedToAnvil = ThumbWheelReporting(isDiverted: true, isInverted: false)

    private var originalReportings: [String: ThumbWheelReporting] = [:]

    func apply(to device: LogitechDevice, on channel: HIDPPChannel) async {
        guard device.kind == .mouse, let thumbWheelFeature = device.thumbWheelFeature,
              let parameters = await channel.send(.thumbWheelReporting(of: device.deviceIndex, thumbWheelFeature: thumbWheelFeature))?.parameters,
              let reporting = ThumbWheelReporting(parameters: parameters)
        else { return }
        let wanted: ThumbWheelReporting?
        if Tool.mouse.isOn {
            originalReportings[device.id] = originalReportings[device.id] ?? ThumbWheelReporting(isDiverted: false, isInverted: reporting.isInverted)
            wanted = Self.divertedToAnvil
        } else {
            wanted = originalReportings.removeValue(forKey: device.id)
        }
        guard let wanted, wanted != reporting else { return }
        _ = await channel.send(.setThumbWheelReporting(wanted, of: device.deviceIndex, thumbWheelFeature: thumbWheelFeature))
    }
}
