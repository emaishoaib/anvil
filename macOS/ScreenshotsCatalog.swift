import LauncherKit

/// The Screenshots tool's settings in the search bar, which is the shortcut that starts a screenshot.
enum ScreenshotsCatalog {
    static func settings(systemShortcuts: Set<KeyCombo>) -> [Setting] {
        let combo = ScreenshotKeys.shared.captureCombo
        let clashes = Tool.screenshots.clashes(with: Shortcut(combo: combo, action: ScreenshotKeys.captureAction), systemShortcuts: systemShortcuts)
        return [
            .shortcut(ScreenshotKeys.captureAction, id: "screenshots.shortcut", toolName: Tool.screenshots.name, combo: combo, canClear: false, clashes: clashes) { combo in
                if let combo { ScreenshotKeys.shared.setCaptureCombo(combo) }
            },
        ]
    }
}
