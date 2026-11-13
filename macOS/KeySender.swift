import CoreGraphics

nonisolated enum KeySender {
    static let marker: Int64 = 0x616E76696C

    static func send(_ combo: KeyCombo) {
        let source = CGEventSource(stateID: .privateState)
        for isDown in [true, false] {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(combo.keyCode), keyDown: isDown) else { continue }
            event.flags = combo.modifiers.flags
            event.setIntegerValueField(.eventSourceUserData, value: marker)
            event.post(tap: .cghidEventTap)
        }
    }
}
