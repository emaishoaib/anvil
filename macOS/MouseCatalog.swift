import LauncherKit
import MouseKit

/// The Mouse tool's settings in the search bar. The thumb wheel and DPI rows appear only when a Logitech device has those features, as in the settings window.
enum MouseCatalog {
    static func settings() -> [Setting] {
        let logitech = LogitechDevices.shared
        let hasThumbWheel = logitech.devices.contains { $0.kind == .mouse && $0.thumbWheelFeature != nil }
        let dpi = logitech.devices.lazy.compactMap { logitech.dpis[$0.id] }.first
        return [
            toggle("Reverse the wheel's direction", id: "mouse.reversesWheel", \.reversesWheel),
            hasThumbWheel ? toggle("Invert the thumb wheel", id: "mouse.reversesThumbWheel", \.reversesThumbWheel) : nil,
            dpi.map(dpiSwitch(for:)),
        ].compactMap { $0 }
    }

    private static func toggle(_ title: String, id: String, _ value: WritableKeyPath<MouseSettings, Bool>) -> Setting {
        let library = MouseSettingsLibrary.shared
        return Setting(
            entry: SettingEntry(id: id, title: title, toolName: Tool.mouse.name),
            warning: library.loadProblem,
            row: .toggle(isOn: library.settings[keyPath: value], set: { library.settings[keyPath: value] = $0 })
        )
    }

    private static func dpiSwitch(for dpi: SensorDPI) -> Setting {
        let library = MouseSettingsLibrary.shared
        return Setting(
            entry: SettingEntry(id: "mouse.setsDPI", title: "Set the DPI", toolName: Tool.mouse.name),
            warning: library.loadProblem,
            row: .toggle(isOn: library.settings.dpi != nil, set: { library.settings.dpi = $0 ? dpi.current : nil })
        )
    }
}
