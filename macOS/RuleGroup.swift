import RulesKit

/// Which rules a rules section lists, which triggers its editor offers, and what a rule added from it starts as.
enum RuleGroup {
    case keysAndApps
    case mouseButtons

    var title: String {
        switch self {
        case .keysAndApps: "Rules"
        case .mouseButtons: "Buttons"
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
