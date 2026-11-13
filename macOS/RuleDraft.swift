import Foundation
import RulesKit

struct RuleDraft: Identifiable {
    let id: UUID
    var triggerKind = RuleTriggerKind.shortcut
    var shortcut: KeyCombo?
    var mouseButton: Int?
    var apps = RuleApps.all
    var actionKind = RuleActionKind.sendShortcut
    var shortcutToSend: KeyCombo?
    var menuItem = ""
    var sound: String?

    init() {
        id = UUID()
    }

    init(_ rule: Rule) {
        id = rule.id
        apps = rule.apps
        fillTrigger(from: rule.trigger)
        fillAction(from: rule.action)
    }

    var rule: Rule? {
        guard let trigger, let action, apps != .only(bundleIDs: []), !triggerKind.isAppEvent || apps.isChosen else { return nil }
        return Rule(id: id, trigger: trigger, apps: apps, action: action)
    }
}
