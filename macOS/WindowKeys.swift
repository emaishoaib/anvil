import Carbon.HIToolbox
import Foundation
import WindowKit

nonisolated final class WindowKeys: KeyResponder {
    static let shared = WindowKeys()

    private let restore = Shortcut(combo: KeyCombo(keyCode: kVK_Delete, modifiers: [.control, .option]), action: "Restore")

    var shortcuts: [Shortcut] { WindowAction.allCases.compactMap(\.shortcut) + [restore] }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown, let work = work(for: press.combo) else { return false }
        if !press.isRepeat { DispatchQueue.main.async { work() } }
        return true
    }

    private func work(for combo: KeyCombo) -> (@MainActor @Sendable () -> Void)? {
        if combo == restore.combo { return { Snapping.shared.restoreFocusedWindow() } }
        guard let action = WindowAction.allCases.first(where: { $0.shortcut?.combo == combo }) else { return nil }
        return { Snapping.shared.snapFocusedWindow(to: action) }
    }
}
