import LauncherKit

/// Builds the rows for values kept in the Mouse tool's section of the settings. Each carries the section's load problem as its warning, because no change is saved while it cannot be read.
enum MouseSettingRows {
    static func setting(_ title: String, id: String, subtitle: String? = nil, row: SettingRow) -> Setting {
        Setting(
            entry: SettingEntry(id: id, title: title, toolName: Tool.mouse.name),
            subtitle: subtitle,
            warning: MouseSettingsLibrary.shared.loadProblem,
            row: row
        )
    }

    static func toggle(_ title: String, id: String, _ value: WritableKeyPath<MouseSettings, Bool>) -> Setting {
        let library = MouseSettingsLibrary.shared
        return setting(title, id: id, row: .toggle(isOn: library.settings[keyPath: value], set: { library.settings[keyPath: value] = $0 }))
    }

    static func choice<Value: Equatable>(_ title: String, id: String, _ value: WritableKeyPath<MouseSettings, Value>, among values: [Value], named name: (Value) -> String) -> Setting {
        let library = MouseSettingsLibrary.shared
        return setting(title, id: id, row: .choice(
            selected: values.firstIndex(of: library.settings[keyPath: value]) ?? 0,
            options: values.map(name),
            pick: { library.settings[keyPath: value] = values[$0] }
        ))
    }

    static func number(_ title: String, id: String, _ value: WritableKeyPath<MouseSettings, Double>, in range: ClosedRange<Double>, step: Double, label: @escaping (Double) -> String) -> Setting {
        let library = MouseSettingsLibrary.shared
        return setting(title, id: id, row: .number(SettingNumber(
            value: library.settings[keyPath: value],
            range: range,
            step: step,
            label: label,
            set: { library.settings[keyPath: value] = $0 }
        )))
    }
}
