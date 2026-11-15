import LauncherKit

/// One setting in the search bar: the entry it is found by, the lines under its title, whether it can be changed right now, and its kind of row.
struct Setting: Identifiable {
    let entry: SettingEntry
    var subtitle: String? = nil
    var warning: String? = nil
    var isDisabled = false
    let row: SettingRow

    var id: String { entry.id }

    /// Places settings under a subheader inside their tool's section.
    static func subgroup(_ name: String, _ settings: [Setting]) -> [Setting] {
        settings.map { $0.placed(in: name) }
    }

    private func placed(in subgroup: String) -> Setting {
        Setting(
            entry: SettingEntry(id: entry.id, title: entry.title, toolName: entry.toolName, keywords: entry.keywords, subgroup: subgroup),
            subtitle: subtitle,
            warning: warning,
            isDisabled: isDisabled,
            row: row
        )
    }
}
