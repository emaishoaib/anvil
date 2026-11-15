import Foundation
import LauncherKit
import MouseKit

/// The Mouse tool's rows for Logitech devices. Each appears only when a device has the feature, as in the settings window. The DPI and the ratchet speed are sent to the mouse only when adjusting ends, so it gets one change rather than one for every step.
enum LogitechCatalog {
    static func settings() -> [Setting] {
        let logitech = LogitechDevices.shared
        let mice = logitech.devices.filter { $0.kind == .mouse }
        let dpi = logitech.devices.lazy.compactMap { logitech.dpis[$0.id] }.first
        let hasRatchet = mice.contains { $0.smartShiftFeature != nil }
        let hasThumbWheel = mice.contains { $0.thumbWheelFeature != nil }
        return (dpi.map(dpiSettings(for:)) ?? [])
            + (hasRatchet ? [disengageSpeed] : [])
            + (hasThumbWheel ? thumbWheel : [])
    }

    private static func dpiSettings(for dpi: SensorDPI) -> [Setting] {
        let library = MouseSettingsLibrary.shared
        let setsDPI = MouseSettingRows.setting("Set the DPI", id: "mouse.setsDPI", row: .toggle(
            isOn: library.settings.dpi != nil,
            set: { library.settings.dpi = $0 ? dpi.current : nil }
        ))
        guard let chosen = library.settings.dpi, dpi.choices.count > 1 else { return [setsDPI] }
        let chosenDPI = MouseSettingRows.setting("DPI", id: "mouse.dpi", subtitle: "Accepts \(dpi.lowest) to \(dpi.highest)", row: .number(SettingNumber(
            value: Double(dpi.nearestIndex(to: chosen)),
            range: 0...Double(dpi.choices.count - 1),
            step: 1,
            label: { dpi.choices[Int($0)].formatted() },
            savesOnlyWhenDone: true,
            set: { library.settings.dpi = dpi.choices[Int($0)] }
        )))
        return [setsDPI, chosenDPI]
    }

    private static var disengageSpeed: Setting {
        let library = MouseSettingsLibrary.shared
        let speeds = SmartShift.disengageSpeeds
        return MouseSettingRows.setting("Ratchet disengage speed", id: "mouse.ratchetDisengageSpeed", subtitle: "How fast a flick frees the wheel", row: .number(SettingNumber(
            value: Double(library.settings.ratchetDisengageSpeed),
            range: Double(speeds.lowerBound)...Double(speeds.upperBound),
            step: 1,
            label: { Int($0) >= speeds.upperBound ? "Always Engage" : "\(Int($0))" },
            savesOnlyWhenDone: true,
            set: { library.settings.ratchetDisengageSpeed = Int($0) }
        )))
    }

    private static var thumbWheel: [Setting] {
        [
            MouseSettingRows.choice("Thumb wheel", id: "mouse.thumbWheelEffect", \.thumbWheelEffect, among: WheelEffect.allCases, named: \.name),
            MouseSettingRows.number("Thumb wheel speed", id: "mouse.thumbWheelSpeedGain", \.thumbWheelSpeedGain, in: MouseSettings.thumbWheelSpeedGains, step: MouseSettings.thumbWheelSpeedGainStep) {
                $0.formatted(.number.precision(.fractionLength(2)))
            },
            MouseSettingRows.toggle("Invert the thumb wheel", id: "mouse.reversesThumbWheel", \.reversesThumbWheel),
        ]
    }
}
