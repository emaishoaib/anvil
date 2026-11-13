import RulesKit

/// Which rules a rules section lists, and what a rule added from that section starts as.
enum RuleGroup {
    case all
    case mouseButtons

    var title: String {
        switch self {
        case .all: "Rules"
        case .mouseButtons: "Buttons"
        }
    }

    var emptyText: String {
        switch self {
        case .all: "No rules yet"
        case .mouseButtons: "No button actions yet"
        }
    }

    var addTitle: String {
        switch self {
        case .all: "Add Rule…"
        case .mouseButtons: "Add Button Action…"
        }
    }

    func contains(_ rule: Rule) -> Bool {
        switch self {
        case .all: true
        case .mouseButtons: rule.trigger.usesMouseButton
        }
    }

    var newDraft: RuleDraft {
        var draft = RuleDraft()
        if self == .mouseButtons { draft.triggerKind = .mouseButton }
        return draft
    }
}
