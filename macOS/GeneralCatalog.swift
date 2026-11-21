import LauncherKit

/// The settings that belong to Anvil as a whole rather than to one tool, listed first under "General". The search bar's own settings are its shortcut and how long it remembers where you left it. The animation setting picks how Anvil shows that it is working. The folder panel opens through the search bar, which stays open behind it.
enum GeneralCatalog {
    static let name = "General"
    static let icon = ToolIcon.symbol("gearshape")

    static func settings(systemShortcuts: Set<KeyCombo>) -> [Setting] {
        Setting.subgroup("Search Bar", [searchBarShortcut(systemShortcuts: systemShortcuts), searchMemory])
            + Setting.subgroup("Animation", [workingAnimation])
            + Setting.subgroup("Settings Folder", settingsFolder)
    }

    private static var workingAnimation: Setting {
        let choices = WorkingAnimation.allCases
        return Setting(
            entry: SettingEntry(id: "general.workingAnimation", title: "While Anvil works", toolName: name, keywords: ["strike", "glow", "loading", "spinner"]),
            row: .choice(selected: choices.firstIndex(of: .current) ?? 0, options: choices.map(\.name), pick: { WorkingAnimation.current = choices[$0] })
        )
    }

    private static func searchBarShortcut(systemShortcuts: Set<KeyCombo>) -> Setting {
        let combo = LauncherKeys.shared.openSearchBarCombo
        let clashes = Tool.launcher.clashes(with: Shortcut(combo: combo, action: "Open Search Bar"), systemShortcuts: systemShortcuts)
        return .shortcut("Open the search bar", id: "launcher.shortcut", toolName: name, combo: combo, canClear: false, clashes: clashes) { combo in
            if let combo { LauncherKeys.shared.setOpenSearchBarCombo(combo) }
        }
    }

    private static var searchMemory: Setting {
        let choices = SearchMemory.allCases
        return Setting(
            entry: SettingEntry(id: "launcher.searchMemory", title: "Remember where you left off for", toolName: name, keywords: ["restore", "last search"]),
            row: .choice(selected: choices.firstIndex(of: .current) ?? 0, options: choices.map(\.name), pick: { SearchMemory.current = choices[$0] })
        )
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
