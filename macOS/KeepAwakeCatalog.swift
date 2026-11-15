import LauncherKit

/// The Keep Awake tool's session switches in the search bar: whether a session is running, and whether it also keeps the Mac awake with the lid closed. Both are dimmed while the tool is off, as the menu bar menu used to hide them, and the lid switch is dimmed while no session runs. Turning either on or off finishes after the rows have been read again, so the rows are read once more when it is done.
enum KeepAwakeCatalog {
    static func settings() -> [Setting] {
        let keepAwake = KeepAwake.shared
        let isToolOff = !Tool.keepAwake.isOn
        return Setting.subgroup("Session", [
            toggle("Keep Awake", id: "keepAwake.session", isOn: keepAwake.isActive, isDisabled: isToolOff) { isOn in
                await keepAwake.setActive(isOn)
            },
            toggle("Stay Awake with Lid Closed", id: "keepAwake.withLidClosed", isOn: keepAwake.staysAwakeWithLidClosed, isDisabled: isToolOff || !keepAwake.isActive) { isOn in
                await keepAwake.setStaysAwakeWithLidClosed(isOn)
            },
        ])
    }

    private static func toggle(_ title: String, id: String, isOn: Bool, isDisabled: Bool, set: @escaping @MainActor (Bool) async -> Void) -> Setting {
        Setting(
            entry: SettingEntry(id: id, title: title, toolName: Tool.keepAwake.name),
            isDisabled: isDisabled,
            row: .toggle(isOn: isOn, set: { isOn in
                Task {
                    await set(isOn)
                    SearchBar.shared.refreshSettings()
                }
            })
        )
    }
}
