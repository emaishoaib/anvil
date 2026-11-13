import Foundation
import WindowKit

nonisolated final class WindowKeys: KeyResponder {
    static let shared = WindowKeys()

    var shortcuts: [Shortcut] { WindowAction.allCases.compactMap(\.shortcut) }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown,
              let action = WindowAction.allCases.first(where: { $0.shortcut?.combo == press.combo })
        else { return false }
        if !press.isRepeat { DispatchQueue.main.async { Snapping.snapFocusedWindow(to: action) } }
        return true
    }
}
