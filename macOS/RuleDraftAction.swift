import RulesKit

extension RuleDraft {
    mutating func fillAction(from action: RuleAction) {
        switch action {
        case .sendShortcut(let keystroke):
            actionKind = .sendShortcut
            shortcutToSend = KeyCombo(keystroke)
        case .chooseMenuItem(let path):
            actionKind = .chooseMenuItem
            menuItem = path.joined(separator: " > ")
        case .playSound(let name):
            actionKind = .playSound
            sound = name
        }
    }

    var action: RuleAction? {
        switch actionKind {
        case .sendShortcut:
            return shortcutToSend.map { .sendShortcut($0.keystroke) }
        case .chooseMenuItem:
            let path = RuleAction.menuPath(from: menuItem)
            return path.isEmpty ? nil : .chooseMenuItem(path: path)
        case .playSound:
            return sound.map { .playSound(name: $0) }
        }
    }
}
