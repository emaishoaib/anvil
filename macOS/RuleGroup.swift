import RulesKit

/// Which rules a rules section lists, which tool it sits in, which triggers its editor offers, and what a rule added from it starts as.
enum RuleGroup {
    case keysAndApps
    case mouseButtons

    var title: String {
        switch self {
        case .keysAndApps: "Rules"
        case .mouseButtons: "Buttons"
        }
    }

    var itemName: String {
        switch self {
        case .keysAndApps: "Rule"
        case .mouseButtons: "Button Action"
        }
    }

    var tool: Tool {
        switch self {
        case .keysAndApps: .rules
        case .mouseButtons: .mouse
        }
    }

    var emptyText: String {
        switch self {
        case .keysAndApps: "No rules yet"
        case .mouseButtons: "No button actions yet"
        }
    }

    var addTitle: String {
        switch self {
        case .keysAndApps: "Add Rule…"
        case .mouseButtons: "Add Button Action…"
        }
    }

    var triggerKinds: [RuleTriggerKind] {
        RuleTriggerKind.allCases.filter { $0.usesMouseButton == (self == .mouseButtons) }
    }

    func contains(_ rule: Rule) -> Bool {
        rule.trigger.usesMouseButton == (self == .mouseButtons)
    }

    var newDraft: RuleDraft {
        var draft = RuleDraft()
        draft.triggerKind = triggerKinds[0]
        return draft
    }
}
