import RulesKit

extension RuleDraft {
    mutating func fillTrigger(from trigger: RuleTrigger) {
        switch trigger {
        case .shortcut(let keystroke):
            triggerKind = .shortcut
            shortcut = KeyCombo(keystroke)
        case .mouseButton(let number):
            triggerKind = .mouseButton
            mouseButton = number
        case .mouseDrag(let number, let direction):
            triggerKind = .mouseDrag
            mouseButton = number
            dragDirection = direction
        case .appOpens:
            triggerKind = .appOpens
        case .appComesToFront:
            triggerKind = .appComesToFront
        }
    }

    var trigger: RuleTrigger? {
        switch triggerKind {
        case .shortcut: shortcut.map { .shortcut($0.keystroke) }
        case .mouseButton: mouseButton.map { .mouseButton(number: $0) }
        case .mouseDrag: mouseButton.map { .mouseDrag(number: $0, direction: dragDirection) }
        case .appOpens: .appOpens
        case .appComesToFront: .appComesToFront
        }
    }
}
