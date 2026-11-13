import Carbon.HIToolbox
import Foundation
import os

nonisolated final class LauncherKeys: KeyResponder {
    static let shared = LauncherKeys()

    private static let savedKey = "launcher.shortcut"
    private static let defaultCombo = KeyCombo(keyCode: kVK_Space, modifiers: .option)
    private static let openSearchBarAction = "Open the search bar"

    private let combo = OSAllocatedUnfairLock(initialState: LauncherKeys.loaded())

    var openSearchBarCombo: KeyCombo { combo.withLock { $0 } }

    var shortcuts: [Shortcut] { [Shortcut(combo: openSearchBarCombo, action: Self.openSearchBarAction)] }

    func setOpenSearchBarCombo(_ newCombo: KeyCombo) {
        combo.withLock { $0 = newCombo }
        UserDefaults.standard.set(newCombo.savedText, forKey: Self.savedKey)
    }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown, press.combo == openSearchBarCombo else { return false }
        if !press.isRepeat { DispatchQueue.main.async { SearchBar.shared.toggle() } }
        return true
    }

    private static func loaded() -> KeyCombo {
        UserDefaults.standard.string(forKey: savedKey).flatMap(KeyCombo.init(savedText:)) ?? defaultCombo
    }
}
