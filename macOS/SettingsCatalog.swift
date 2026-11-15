import LauncherKit

/// Every setting the search bar can show, in the order of the settings window's sidebar, read afresh each time so every row holds its current value.
enum SettingsCatalog {
    static func settings() -> [Setting] {
        Tool.allCases.flatMap { tool in
            (tool.canBeTurnedOff ? [toolSwitch(for: tool)] : []) + settings(of: tool)
        }
    }

    private static func settings(of tool: Tool) -> [Setting] {
        switch tool {
        case .windows: WindowsCatalog.settings()
        case .mouse: MouseCatalog.settings()
        default: []
        }
    }

    private static func toolSwitch(for tool: Tool) -> Setting {
        Setting(
            entry: SettingEntry(id: tool.isOnKey, title: "Use \(tool.name)", toolName: tool.name),
            subtitle: tool.summary,
            row: .toggle(isOn: tool.isOn, set: { tool.setOn($0) })
        )
    }
}
