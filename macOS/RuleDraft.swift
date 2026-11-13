import Foundation
import RulesKit

struct RuleDraft: Identifiable {
    let id: UUID
    var trigger: KeyCombo?
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
        switch rule.trigger {
        case .shortcut(let keystroke): trigger = KeyCombo(keystroke)
        }
        switch rule.action {
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

    var rule: Rule? {
        guard let trigger, let action, apps != .only(bundleIDs: []) else { return nil }
        return Rule(id: id, trigger: .shortcut(trigger.keystroke), apps: apps, action: action)
    }

    private var action: RuleAction? {
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
