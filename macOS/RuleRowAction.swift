import Carbon.HIToolbox
import LauncherKit

/// What the action panel offers for a rule in settings mode, with the same shortcuts as editing and deleting a quick link.
enum RuleRowAction: CaseIterable {
    case edit, delete

    var name: String {
        switch self {
        case .edit: "Edit Rule"
        case .delete: "Delete Rule"
        }
    }

    var symbol: String {
        switch self {
        case .edit: "pencil"
        case .delete: "trash"
        }
    }

    var isDestructive: Bool { self == .delete }

    var shortcut: KeyCombo {
        switch self {
        case .edit: KeyCombo(keyCode: kVK_ANSI_E, modifiers: .command)
        case .delete: KeyCombo(keyCode: kVK_ANSI_X, modifiers: .control)
        }
    }

    static func matching(_ filter: String) -> [RuleRowAction] {
        let filter = filter.trimmingCharacters(in: .whitespaces)
        guard !filter.isEmpty else { return allCases }
        return allCases.filter { NameMatch(name: $0.name, query: filter) != nil }
    }

    static func forShortcut(_ combo: KeyCombo) -> RuleRowAction? {
        allCases.first { $0.shortcut == combo }
    }
}
