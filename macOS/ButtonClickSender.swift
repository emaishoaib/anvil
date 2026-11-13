import CoreGraphics

nonisolated enum ButtonClickSender {
    static func send(button number: Int, at point: CGPoint) {
        for type in [CGEventType.otherMouseDown, .otherMouseUp] {
            guard let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: point, mouseButton: .center) else { continue }
            event.setIntegerValueField(.mouseEventButtonNumber, value: Int64(number))
            event.setIntegerValueField(.mouseEventClickState, value: 1)
            event.setIntegerValueField(.eventSourceUserData, value: KeySender.marker)
            event.post(tap: .cghidEventTap)
        }
    }
}
