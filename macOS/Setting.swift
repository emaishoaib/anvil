import LauncherKit

/// One setting in the search bar: the entry it is found by, the lines under its title, whether it can be changed right now, and its kind of row.
struct Setting: Identifiable {
    let entry: SettingEntry
    var subtitle: String? = nil
    var warning: String? = nil
    var isDisabled = false
    let row: SettingRow

    var id: String { entry.id }
}
