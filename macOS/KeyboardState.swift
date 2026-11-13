import Carbon.HIToolbox

nonisolated enum KeyboardState {
    case closed(lastNumber: Int)
    case open(number: Int)

    mutating func action(for press: KeyPress) -> SwitchAction? {
        let optionHeld = press.modifiers.contains(.option)
        switch (press.kind, self) {
        case (.keyDown, .open(let number)) where optionHeld:
            if press.keyCode == kVK_Escape {
                self = .closed(lastNumber: number)
                return .cancel
            }
            if let direction = SwitchDirection(keyCode: press.keyCode) { return .move(direction) }
            return SwitchScope(keyCode: press.keyCode) == nil ? nil : .next
        case (.keyDown, .closed(let lastNumber)):
            guard let scope = SwitchScope(combo: press.combo) else { return nil }
            self = .open(number: lastNumber + 1)
            return .open(scope, number: lastNumber + 1)
        case (.modifiersChanged, .open(let number)) where !optionHeld:
            self = .closed(lastNumber: number)
            return .release
        default:
            return nil
        }
    }

    mutating func end(_ number: Int) {
        if case .open(number) = self { self = .closed(lastNumber: number) }
    }
}
