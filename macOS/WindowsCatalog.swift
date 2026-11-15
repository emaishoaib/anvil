import Foundation
import LauncherKit
import WindowKit

/// The Windows tool's settings in the search bar. The snap zones can only be changed while snapping by dragging is on.
enum WindowsCatalog {
    static func settings() -> [Setting] {
        [
            toggle("Snap windows by dragging them to the screen edges", key: SnappingSettings.snapsByDraggingKey, isOn: SnappingSettings.snapsByDragging),
            toggle("Restore a window's size when dragged out of a snap", key: SnappingSettings.restoresSizeWhenUnsnappedKey, isOn: SnappingSettings.restoresSizeWhenUnsnapped),
            toggle("Maximize or restore a window by double-clicking its title bar", key: SnappingSettings.maximizesOnTitleBarDoubleClickKey, isOn: SnappingSettings.maximizesOnTitleBarDoubleClick, warning: doubleClickWarning),
            gap,
        ] + SnapZone.allCases.map(zoneChoice(for:))
    }

    private static var gap: Setting {
        Setting(
            entry: SettingEntry(id: SnappingSettings.gapKey, title: "Gap between windows", toolName: Tool.windows.name),
            row: .number(SettingNumber(
                value: Double(SnappingSettings.gap),
                range: SnappingSettings.gapRange,
                step: 1,
                label: { "\(Int($0)) pt" },
                set: { UserDefaults.standard.set($0, forKey: SnappingSettings.gapKey) }
            ))
        )
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

    private static func zoneChoice(for zone: SnapZone) -> Setting {
        let key = SnappingSettings.choiceKey(for: zone)
        let choices = zone.choices
        return Setting(
            entry: SettingEntry(id: key, title: zone.title, toolName: Tool.windows.name, keywords: ["snap zone"]),
            subtitle: "Snap zone",
            isDisabled: !SnappingSettings.snapsByDragging,
            row: .choice(
                selected: choices.firstIndex(of: SnappingSettings.choice(for: zone)) ?? 0,
                options: choices.map { $0.title(in: zone) },
                pick: { UserDefaults.standard.set(choices[$0].rawValue, forKey: key) }
            )
        )
    }
}
