import LauncherKit

/// Every setting the search bar can show, read afresh each time so every row holds its current value.
enum SettingsCatalog {
    static func settings() -> [Setting] {
        Tool.allCases.filter(\.canBeTurnedOff).map(toolSwitch(for:))
    }

    private static func toolSwitch(for tool: Tool) -> Setting {
        Setting(
            entry: SettingEntry(id: tool.isOnKey, title: "Use \(tool.name)", toolName: tool.name),
            subtitle: tool.summary,
            row: .toggle(isOn: tool.isOn, set: { tool.setOn($0) })
        )
    }
}
