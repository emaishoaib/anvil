/// The settings that belong to Anvil as a whole rather than to one tool, listed first under "General", as in the settings window's sidebar. The folder panel opens through the search bar, which stays open behind it.
enum GeneralCatalog {
    static let name = "General"

    static func settings(systemShortcuts: Set<KeyCombo>) -> [Setting] {
        Setting.subgroup("Search Bar", [searchBarShortcut(systemShortcuts: systemShortcuts)])
            + Setting.subgroup("Settings Folder", settingsFolder)
    }

    private static func searchBarShortcut(systemShortcuts: Set<KeyCombo>) -> Setting {
        let combo = LauncherKeys.shared.openSearchBarCombo
        let clashes = Tool.launcher.clashes(with: Shortcut(combo: combo, action: "Open Search Bar"), systemShortcuts: systemShortcuts)
        return .shortcut("Open the search bar", id: "launcher.shortcut", toolName: name, combo: combo, canClear: false, clashes: clashes) { combo in
            if let combo { LauncherKeys.shared.setOpenSearchBarCombo(combo) }
        }
    }

    private static var settingsFolder: [Setting] {
        let folder = SettingsFolder.shared
        let path = Setting.info("Settings folder", id: "general.settingsFolder", toolName: name, value: folder.displayPath)
        let choose = Setting.action("Choose Settings Folder", id: "general.chooseSettingsFolder", toolName: name) {
            SearchBar.shared.presentModal(folder.choose)
            return nil
        }
        guard folder.url != nil else { return [path, choose] }
        return [
            path,
            choose,
            .action("Use Anvil's Settings", id: "general.useAnvilSettings", toolName: name) {
                folder.useSettings()
                return nil
            },
            .action("Reload Settings", id: "general.reloadSettings", toolName: name) {
                folder.reload()
                return nil
            },
        ]
    }
}
