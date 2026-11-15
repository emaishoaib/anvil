import LauncherKit

/// The Mouse tool's settings in the search bar, in the settings window's order: scrolling, the keys that change what the wheel does, then the rows for Logitech devices.
enum MouseCatalog {
    static func settings() -> [Setting] {
        Setting.subgroup("Scrolling", scrolling)
            + Setting.subgroup("While Holding a Key", whileHoldingAKey)
            + Setting.subgroup("Logitech", LogitechCatalog.settings())
    }

    private static var scrolling: [Setting] {
        [
            MouseSettingRows.toggle("Reverse the wheel's direction", id: "mouse.reversesWheel", \.reversesWheel),
            durationFrames,
            brakeFrame,
            MouseSettingRows.number("Distance of each wheel click", id: "mouse.pointsPerTick", \.pointsPerTick, in: ScrollingSettings.pointsPerTickRange, step: 5) { "\(Int($0)) pt" },
            MouseSettingRows.number("Acceleration", id: "mouse.acceleration", \.acceleration, in: ScrollingSettings.accelerationRange, step: 0.05) { "\(Int(($0 * 100).rounded()))%" },
        ]
    }

    private static var whileHoldingAKey: [Setting] {
        [
            .info("Shift scrolls sideways", id: "mouse.shiftScrollsSideways", toolName: Tool.mouse.name),
            .info("Control zooms in and out", id: "mouse.controlZooms", toolName: Tool.mouse.name),
            MouseSettingRows.choice("Scroll speed while holding Command", id: "mouse.commandScrollSpeed", \.commandScrollSpeed, among: CommandScrollSpeed.allCases) { "\($0.name) the speed" },
        ]
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
