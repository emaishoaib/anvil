import LauncherKit

extension Setting {
    /// A row that records a shortcut, carrying an orange warning when the shortcut is also used by another tool or by macOS.
    static func shortcut(_ title: String, id: String, toolName: String, combo: KeyCombo?, canClear: Bool, clashes: [ShortcutClash], record: @escaping @MainActor (KeyCombo?) -> Void) -> Setting {
        Setting(
            entry: SettingEntry(id: id, title: title, toolName: toolName, keywords: ["shortcut"]),
            warning: ShortcutClash.warning(for: clashes),
            row: .shortcut(combo: combo, canClear: canClear, record: record)
        )
    }
}
