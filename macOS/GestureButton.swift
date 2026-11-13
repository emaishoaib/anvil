import CoreGraphics
import MouseKit

enum GestureButton {
    nonisolated static let number = 6

    static func takeOver(_ device: LogitechDevice, on channel: HIDPPChannel) async {
        guard device.kind == .mouse, let controlsFeature = device.controlsFeature else { return }
        _ = await channel.send(.reporting(
            of: HIDPPRequest.buttonBehindWheelControl,
            on: device.deviceIndex,
            controlsFeature: controlsFeature,
            diverted: Tool.mouse.isOn
        ))
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
}
