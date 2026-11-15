import LauncherKit

extension Setting {
    /// A row that runs something when Return is pressed on it, such as choosing the settings folder.
    static func action(_ title: String, id: String, toolName: String, isDisabled: Bool = false, run: @escaping @MainActor () -> String?) -> Setting {
        Setting(entry: SettingEntry(id: id, title: title, toolName: toolName), isDisabled: isDisabled, row: .action(run: run))
    }

    /// A row that only shows something, such as a fixed shortcut or a device's battery.
    static func info(_ title: String, id: String, toolName: String, subtitle: String? = nil, value: String? = nil, keywords: [String] = []) -> Setting {
        Setting(entry: SettingEntry(id: id, title: title, toolName: toolName, keywords: keywords), subtitle: subtitle, row: .info(value: value))
    }
}
