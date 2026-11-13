import Foundation
import RulesKit

struct RuleDraft: Identifiable {
    let id: UUID
    var trigger: KeyCombo?
    var apps: RuleApps
    var shortcutToSend: KeyCombo?

    init() {
        id = UUID()
        apps = .all
    }

    init(_ rule: Rule) {
        id = rule.id
        apps = rule.apps
        switch rule.trigger {
        case .shortcut(let keystroke): trigger = KeyCombo(keystroke)
        }
        switch rule.action {
        case .sendShortcut(let keystroke): shortcutToSend = KeyCombo(keystroke)
        }
    }

    var rule: Rule? {
        guard let trigger, let shortcutToSend, apps != .only(bundleIDs: []) else { return nil }
        return Rule(id: id, trigger: .shortcut(trigger.keystroke), apps: apps, action: .sendShortcut(shortcutToSend.keystroke))
    }
}
