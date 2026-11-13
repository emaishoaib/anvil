import Carbon.HIToolbox
import Foundation

nonisolated final class LauncherKeys: KeyResponder {
    static let shared = LauncherKeys()

    private let openSearchBar = Shortcut(combo: KeyCombo(keyCode: kVK_Space, modifiers: .option), action: "Open the search bar")

    var shortcuts: [Shortcut] { [openSearchBar] }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown, press.combo == openSearchBar.combo else { return false }
        if !press.isRepeat { DispatchQueue.main.async { SearchBar.shared.toggle() } }
        return true
    }
}
