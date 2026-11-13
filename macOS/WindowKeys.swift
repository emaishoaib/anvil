import Foundation

nonisolated final class WindowKeys: KeyResponder {
    static let shared = WindowKeys()

    var shortcuts: [Shortcut] {
        let combos = WindowShortcuts.shared.all
        return WindowCommand.allCases.compactMap { command in
            combos[command].map { Shortcut(combo: $0, action: command.title) }
        }
    }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown, let command = WindowShortcuts.shared.command(for: press.combo) else { return false }
        if !press.isRepeat { DispatchQueue.main.async { command.perform() } }
        return true
    }
}
