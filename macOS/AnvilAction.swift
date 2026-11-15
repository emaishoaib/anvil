import Carbon.HIToolbox
import LauncherKit

/// An action about Anvil itself, listed in the search bar's Anvil menu.
enum AnvilAction: CaseIterable {
    case checkForUpdates, quit

    var name: String {
        switch self {
        case .checkForUpdates: "Check for Updates"
        case .quit: "Quit Anvil"
        }
    }

    var symbol: String {
        switch self {
        case .checkForUpdates: "arrow.down.circle"
        case .quit: "power"
        }
    }

    var shortcut: KeyCombo? {
        switch self {
        case .checkForUpdates: nil
        case .quit: KeyCombo(keyCode: kVK_ANSI_Q, modifiers: .command)
        }
    }

    static func matching(_ filter: String) -> [AnvilAction] {
        let filter = filter.trimmingCharacters(in: .whitespaces)
        let available = allCases.filter { $0 != .checkForUpdates || AppUpdater.shared.canCheck }
        guard !filter.isEmpty else { return available }
        return available.filter { NameMatch(name: $0.name, query: filter) != nil }
    }

    static func forShortcut(_ combo: KeyCombo) -> AnvilAction? {
        allCases.first { $0.shortcut == combo }
    }
}
