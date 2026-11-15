import LauncherKit

/// One setting in the search bar: the entry it is found by, the line under its title, and its kind of row.
struct Setting: Identifiable {
    let entry: SettingEntry
    let subtitle: String?
    let row: SettingRow

    var id: String { entry.id }
}
