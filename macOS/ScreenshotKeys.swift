import Carbon.HIToolbox
import Foundation
import os

/// The Screenshots tool's shortcut, which lets you drag over part of the screen from any app and then shows the screenshot in the search bar. It answers only while the tool is on. The shortcut is kept in its own section of the settings, so it follows the settings folder, and it is read again whenever the folder or its settings file changes. A section that cannot be read leaves the shortcut as it was and is never written over.
nonisolated final class ScreenshotKeys: KeyResponder {
    static let shared = ScreenshotKeys()

    private static let section = "screenshots"
    private static let oldFile = "screenshots.json"
    private static let settingsKey = "screenshots.settings"
    private static let defaultCombo = KeyCombo(keyCode: kVK_ANSI_4, modifiers: [.option, .shift])
    static let captureAction = "Take a screenshot"

    private let combo = OSAllocatedUnfairLock(initialState: ScreenshotKeys.defaultCombo)

    var captureCombo: KeyCombo { combo.withLock { $0 } }

    var shortcuts: [Shortcut] { [Shortcut(combo: captureCombo, action: Self.captureAction)] }

    @MainActor func reload() {
        do {
            guard let saved = try SettingsStorage.load(ScreenshotSettings.self, section: Self.section, oldFile: Self.oldFile, settingsKey: Self.settingsKey) else { return persist() }
            guard let savedCombo = KeyCombo(savedText: saved.shortcut) else { return }
            combo.withLock { $0 = savedCombo }
        } catch {
            return
        }
    }

    @MainActor func setCaptureCombo(_ newCombo: KeyCombo) {
        combo.withLock { $0 = newCombo }
        persist()
    }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown, press.combo == captureCombo else { return false }
        if !press.isRepeat { DispatchQueue.main.async { SearchBar.shared.takeScreenshot() } }
        return true
    }

    @MainActor private func persist() {
        SettingsStorage.save(ScreenshotSettings(shortcut: captureCombo.savedText), section: Self.section, settingsKey: Self.settingsKey)
    }
}
