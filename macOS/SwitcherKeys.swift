import Foundation
import os

nonisolated final class SwitcherKeys: KeyResponder {
    static let shared = SwitcherKeys()

    private let state = OSAllocatedUnfairLock(initialState: KeyboardState.closed(lastNumber: 0))

    var shortcuts: [Shortcut] { SwitchScope.allCases.map(\.shortcut) }

    func respond(to press: KeyPress) -> Bool {
        guard let action = state.withLock({ $0.action(for: press) }) else { return false }
        DispatchQueue.main.async { Switcher.shared.perform(action) }
        return press.kind == .keyDown
    }

    func switchEnded(_ number: Int) {
        state.withLock { $0.end(number) }
    }
}
