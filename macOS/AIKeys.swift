import Carbon.HIToolbox
import Foundation
import os

/// The AI tool's shortcut, which starts listening on one press and stops on the next, from any app. It answers only while the AI tool is on.
nonisolated final class AIKeys: KeyResponder {
    static let shared = AIKeys()

    static let savedKey = "ai.listenShortcut"
    static let defaultCombo = KeyCombo(keyCode: kVK_Space, modifiers: [.option, .shift])
    private static let listenAction = "Start or stop listening"

    private let combo = OSAllocatedUnfairLock(initialState: AIKeys.loaded())

    var listenCombo: KeyCombo { combo.withLock { $0 } }

    var shortcuts: [Shortcut] { [Shortcut(combo: listenCombo, action: Self.listenAction)] }

    /// Reads the shortcut again, as when the settings folder brings in a new one.
    func reload() {
        combo.withLock { $0 = Self.loaded() }
    }

    func setListenCombo(_ newCombo: KeyCombo) {
        combo.withLock { $0 = newCombo }
        UserDefaults.standard.set(newCombo.savedText, forKey: Self.savedKey)
    }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown, press.combo == listenCombo else { return false }
        if !press.isRepeat { DispatchQueue.main.async { Listener.shared.toggle() } }
        return true
    }

    private static func loaded() -> KeyCombo {
        UserDefaults.standard.string(forKey: savedKey).flatMap(KeyCombo.init(savedText:)) ?? defaultCombo
    }
}
