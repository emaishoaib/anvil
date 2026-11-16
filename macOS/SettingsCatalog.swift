import LauncherKit

/// Every setting the search bar can show, in the order of the settings window's sidebar, read afresh each time so every row holds its current value. Shortcuts are checked for clashes against the system shortcuts passed in, so macOS is asked only once.
enum SettingsCatalog {
    static func settings(systemShortcuts: Set<KeyCombo>) -> [Setting] {
        GeneralCatalog.settings(systemShortcuts: systemShortcuts) + Tool.allCases.flatMap { tool in
            (tool.canBeTurnedOff ? [toolSwitch(for: tool)] : []) + settings(of: tool, systemShortcuts: systemShortcuts)
        }
    }

    private static func settings(of tool: Tool, systemShortcuts: Set<KeyCombo>) -> [Setting] {
        switch tool {
        case .switcher: switcherShortcuts
        case .launcher: LauncherCatalog.settings()
        case .windows: WindowsCatalog.settings(systemShortcuts: systemShortcuts)
        case .keepAwake: KeepAwakeCatalog.settings()
        case .rules:
            Setting.subgroup(RuleGroup.keysAndApps.title, RulesCatalog.settings(for: .keysAndApps, systemShortcuts: systemShortcuts))
                + Setting.subgroup("Key Swaps", KeySwapsCatalog.settings())
        case .mouse: MouseCatalog.settings(systemShortcuts: systemShortcuts)
        case .uninstaller: UninstallerCatalog.settings()
        case .ai: AICatalog.settings()
        default: []
        }
    }

    private static var switcherShortcuts: [Setting] {
        Setting.subgroup("Shortcuts", Tool.switcher.shortcuts.map { shortcut in
            .info(shortcut.action, id: "switcher.\(shortcut.keys)", toolName: Tool.switcher.name, value: shortcut.keys, keywords: ["shortcut"])
        })
    }

    private static func toolSwitch(for tool: Tool) -> Setting {
        Setting(
            entry: SettingEntry(id: tool.isOnKey, title: "Use \(tool.name)", toolName: tool.name),
            subtitle: tool.summary,
            row: .toggle(isOn: tool.isOn, set: { tool.setOn($0) })
        )
    }
}
