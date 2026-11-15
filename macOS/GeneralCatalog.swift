/// The settings that belong to Anvil as a whole rather than to one tool, listed first under "General", as in the settings window's sidebar.
enum GeneralCatalog {
    static let name = "General"

    static func settings(systemShortcuts: Set<KeyCombo>) -> [Setting] {
        let combo = LauncherKeys.shared.openSearchBarCombo
        let clashes = Tool.launcher.clashes(with: Shortcut(combo: combo, action: "Open Search Bar"), systemShortcuts: systemShortcuts)
        return [
            .shortcut("Open the search bar", id: "launcher.shortcut", toolName: name, combo: combo, canClear: false, clashes: clashes) { combo in
                if let combo { LauncherKeys.shared.setOpenSearchBarCombo(combo) }
            },
        ]
    }
}
