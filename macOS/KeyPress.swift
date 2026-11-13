import CoreGraphics

nonisolated enum KeyPressKind {
    case keyDown, modifiersChanged
}

nonisolated struct KeyPress {
    let kind: KeyPressKind
    let keyCode: Int
    let modifiers: KeyModifiers

    var combo: KeyCombo { KeyCombo(keyCode: keyCode, modifiers: modifiers) }

    init?(_ type: CGEventType, _ event: CGEvent) {
        let kind: KeyPressKind? = switch type {
        case .keyDown: .keyDown
        case .flagsChanged: .modifiersChanged
        default: nil
        }
        guard let kind else { return nil }
        self.kind = kind
        keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        modifiers = KeyModifiers(flags: event.flags)
    }
}
