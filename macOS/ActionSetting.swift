import LauncherKit

extension Setting {
    /// A row that runs something when Return is pressed on it, such as choosing the settings folder. The footer names the action, "Run" unless given another name.
    static func action(_ title: String, id: String, toolName: String, subtitle: String? = nil, actionTitle: String = "Run", isDisabled: Bool = false, run: @escaping @MainActor () -> String?) -> Setting {
        Setting(entry: SettingEntry(id: id, title: title, toolName: toolName), subtitle: subtitle, isDisabled: isDisabled, row: .action(title: actionTitle, run: run))
    }

    /// A row that opens a page of settings, such as a tool's page or one of its subgroups.
    static func page(_ page: SettingsBarPage) -> Setting {
        Setting(entry: SettingEntry(id: page.id, title: page.title, toolName: ""), row: .page(page))
    }

    /// A row that only shows something, such as a fixed shortcut or a device's battery.
    static func info(_ title: String, id: String, toolName: String, subtitle: String? = nil, value: String? = nil, keywords: [String] = []) -> Setting {
        Setting(entry: SettingEntry(id: id, title: title, toolName: toolName, keywords: keywords), subtitle: subtitle, row: .info(value: value))
    }
}
