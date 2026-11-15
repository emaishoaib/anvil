import LauncherKit

/// The Mouse tool's settings in the search bar, in the settings window's order: the wheel and scrolling, then the rows for Logitech devices.
enum MouseCatalog {
    static func settings() -> [Setting] {
        [
            MouseSettingRows.toggle("Reverse the wheel's direction", id: "mouse.reversesWheel", \.reversesWheel),
            durationFrames,
            brakeFrame,
            MouseSettingRows.number("Distance of each wheel click", id: "mouse.pointsPerTick", \.pointsPerTick, in: ScrollingSettings.pointsPerTickRange, step: 5) { "\(Int($0)) pt" },
            MouseSettingRows.number("Acceleration", id: "mouse.acceleration", \.acceleration, in: ScrollingSettings.accelerationRange, step: 0.05) { "\(Int(($0 * 100).rounded()))%" },
            MouseSettingRows.choice("Scroll speed while holding Command", id: "mouse.commandScrollSpeed", \.commandScrollSpeed, among: CommandScrollSpeed.allCases) { "\($0.name) the speed" },
        ] + LogitechCatalog.settings()
    }

    private static var durationFrames: Setting {
        let library = MouseSettingsLibrary.shared
        return MouseSettingRows.setting("Duration of each wheel click", id: "mouse.durationFrames", row: .number(SettingNumber(
            value: Double(library.settings.durationFrames),
            range: ScrollingSettings.durationFramesRange,
            step: 1,
            label: { "\(ScrollingSettings.milliseconds(frames: $0)) ms" },
            set: { frames in
                library.settings.durationFrames = Int(frames)
                library.settings.brakeFrame = min(library.settings.brakeFrame, Int(frames))
            }
        )))
    }

    private static var brakeFrame: Setting {
        let library = MouseSettingsLibrary.shared
        return MouseSettingRows.setting("Start slowing down after", id: "mouse.brakeFrame", row: .number(SettingNumber(
            value: Double(library.settings.brakeFrame),
            range: 1...Double(library.settings.durationFrames),
            step: 1,
            label: { "\(ScrollingSettings.milliseconds(frames: $0)) ms" },
            set: { library.settings.brakeFrame = Int($0) }
        )))
    }
}
