import LauncherKit
import RulesKit

/// One rule group's rows in the search bar: a row to add one at the top, then a row per rule showing its trigger, action and apps. While the rules file can't be read, its problem shows as a warning row and the other rows can't be used.
enum RulesCatalog {
    static func settings(for group: RuleGroup, systemShortcuts: Set<KeyCombo>) -> [Setting] {
        let library = RuleLibrary.shared
        let rules = library.all.filter(group.contains)
        let isBroken = library.loadProblem != nil
        return problem(in: group)
            + [addRule(to: group, isDisabled: isBroken)]
            + (rules.isEmpty && !isBroken ? [.info(group.emptyText, id: "rules.empty.\(group)", toolName: group.tool.name)] : [])
            + rules.map { row(for: $0, in: group, isDisabled: isBroken, systemShortcuts: systemShortcuts) }
    }

    private static func problem(in group: RuleGroup) -> [Setting] {
        guard let problem = RuleLibrary.shared.loadProblem else { return [] }
        var row = Setting.info("Rules can't be changed", id: "rules.problem.\(group)", toolName: group.tool.name)
        row.warning = problem
        return [row]
    }

    private static func row(for rule: Rule, in group: RuleGroup, isDisabled: Bool, systemShortcuts: Set<KeyCombo>) -> Setting {
        Setting(
            entry: SettingEntry(id: "rule.\(rule.id)", title: "\(rule.trigger.text) \(rule.action.text)", toolName: group.tool.name, keywords: [rule.apps.summary]),
            subtitle: rule.apps.summary,
            warning: ShortcutClash.warning(for: clashes(of: rule, systemShortcuts: systemShortcuts)),
            isDisabled: isDisabled,
            row: .rule(rule)
        )
    }

    private static func clashes(of rule: Rule, systemShortcuts: Set<KeyCombo>) -> [ShortcutClash] {
        guard case .shortcut(let keystroke) = rule.trigger else { return [] }
        return Tool.rules.clashes(with: Shortcut(combo: KeyCombo(keystroke), action: ""), systemShortcuts: systemShortcuts)
    }

    private static func addRule(to group: RuleGroup, isDisabled: Bool) -> Setting {
        .action("Add \(group.itemName)", id: "rules.add.\(group)", toolName: group.tool.name, isDisabled: isDisabled) {
            SearchBar.shared.showRuleForm(group.newDraft, in: group, isNew: true)
            return nil
        }
    }
}
