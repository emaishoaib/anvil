import RulesKit

nonisolated enum RuleActions {
    static func perform(_ action: RuleAction) {
        switch action {
        case .sendShortcut(let keystroke): KeySender.send(KeyCombo(keystroke))
        }
    }
}
