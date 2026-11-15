import Foundation
import LauncherKit

/// The Windows tool's settings in the search bar.
enum WindowsCatalog {
    static func settings() -> [Setting] {
        [
            toggle("Snap windows by dragging them to the screen edges", key: SnappingSettings.snapsByDraggingKey, isOn: SnappingSettings.snapsByDragging),
            toggle("Restore a window's size when dragged out of a snap", key: SnappingSettings.restoresSizeWhenUnsnappedKey, isOn: SnappingSettings.restoresSizeWhenUnsnapped),
            toggle("Maximize or restore a window by double-clicking its title bar", key: SnappingSettings.maximizesOnTitleBarDoubleClickKey, isOn: SnappingSettings.maximizesOnTitleBarDoubleClick, warning: doubleClickWarning),
        ]
    }

    private static var doubleClickWarning: String? {
        guard SnappingSettings.maximizesOnTitleBarDoubleClick, SnappingSettings.macOSActsOnTitleBarDoubleClick else { return nil }
        return SnappingSettings.macOSDoubleClickWarning
    }

    private static func toggle(_ title: String, key: String, isOn: Bool, warning: String? = nil) -> Setting {
        Setting(
            entry: SettingEntry(id: key, title: title, toolName: Tool.windows.name),
            warning: warning,
            row: .toggle(isOn: isOn, set: { UserDefaults.standard.set($0, forKey: key) })
        )
    }
}
