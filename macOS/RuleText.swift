import RulesKit

extension RuleTrigger {
    /// The trigger in words, as a rule's row shows it and as the search bar matches it.
    var text: String {
        switch self {
        case .shortcut(let keystroke): KeyCombo(keystroke).description
        case .mouseButton(let number): MouseButton.name(for: number)
        case .mouseDrag(let number, let direction): "\(MouseButton.name(for: number)) dragged \(direction.rawValue)"
        case .appOpens: "App opens"
        case .appComesToFront: "App comes to front"
        }
    }
}

extension RuleAction {
    /// The action in words, as a rule's row shows it and as the search bar matches it.
    var text: String {
        switch self {
        case .sendShortcut(let keystroke): "Send \(KeyCombo(keystroke).description)"
        case .chooseMenuItem(let path): "Choose \(path.joined(separator: " > "))"
        case .playSound(let name): "Play \(name)"
        case .quitApp: "Quit it"
        case .resizeWindow(let width, let height): "Resize its window to \(width) by \(height)"
        case .swipe(let direction): direction == .back ? "Swipe back" : "Swipe forward"
        case .playOrPauseMedia: "Play or pause media"
        }
    }
}
