import CoreGraphics
import MouseKit
import os

enum GestureButton {
    nonisolated static let number = 6

    /// Diverts the button behind the wheel to Anvil while the mouse tool is on, and hands it back to the mouse when the tool is off. It reads the button first and writes only when the mouse does not already report it as wanted, or cannot say how it reports it. Each time, it logs what it read and whether it wrote.
    static func apply(to device: LogitechDevice, on channel: HIDPPChannel) async {
        guard device.kind == .mouse, let controlsFeature = device.controlsFeature else { return }
        let control = HIDPPRequest.buttonBehindWheelControl
        let parameters = await channel.send(.controlReporting(of: control, on: device.deviceIndex, controlsFeature: controlsFeature))?.parameters
        let reporting = parameters.flatMap(ControlReporting.init(parameters:))
        let wanted = ControlReporting(isDiverted: Tool.mouse.isOn)
        guard reporting != wanted else {
            Logger.logitech.info("Gesture button on \(device.name, privacy: .public) is \(describe(reporting), privacy: .public), left as it is")
            return
        }
        _ = await channel.send(.reporting(of: control, on: device.deviceIndex, controlsFeature: controlsFeature, diverted: wanted.isDiverted))
        Logger.logitech.notice("Gesture button on \(device.name, privacy: .public) was \(describe(reporting), privacy: .public), set to \(describe(wanted), privacy: .public)")
    }

    static func send(isDown: Bool) {
        let location = CGEvent(source: nil)?.location ?? .zero
        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: isDown ? .otherMouseDown : .otherMouseUp,
            mouseCursorPosition: location,
            mouseButton: .center
        ) else { return }
        event.setIntegerValueField(.mouseEventButtonNumber, value: Int64(number))
        event.post(tap: .cghidEventTap)
    }

    private static func describe(_ reporting: ControlReporting?) -> String {
        switch reporting?.isDiverted {
        case true: "diverted to Anvil"
        case false: "handled by the mouse"
        case nil: "unreadable"
        }
    }
}
