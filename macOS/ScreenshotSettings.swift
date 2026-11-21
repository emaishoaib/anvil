/// The Screenshots tool's settings as written to `screenshots.json` in the settings folder, or kept in Anvil's own settings when there is no folder: the shortcut that starts a screenshot, written the way Anvil writes every shortcut.
struct ScreenshotSettings: Codable, Equatable {
    var shortcut: String
}
