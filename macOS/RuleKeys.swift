import AppKit
import os
import RulesKit

nonisolated final class RuleKeys: KeyResponder {
    static let shared = RuleKeys()

    private let rules = OSAllocatedUnfairLock(initialState: Rules())
    private let frontmostBundleID = OSAllocatedUnfairLock<String?>(initialState: nil)

    var shortcuts: [Shortcut] {
        rules.withLock { $0.rules }.compactMap { rule in
            guard case .shortcut(let keystroke) = rule.trigger else { return nil }
            return Shortcut(combo: KeyCombo(keystroke), action: "Rule")
        }
    }

    @MainActor func start() {
        use(RuleLibrary.shared.rules)
        let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        frontmostBundleID.withLock { $0 = bundleID }
        NSWorkspace.shared.onAppChange(NSWorkspace.didActivateApplicationNotification) { [self] pid in
            let bundleID = NSRunningApplication(processIdentifier: pid)?.bundleIdentifier
            frontmostBundleID.withLock { $0 = bundleID }
        }
    }

    func use(_ newRules: Rules) {
        rules.withLock { $0 = newRules }
    }

    func respond(toMouseButton number: Int, isDown: Bool) -> Bool {
        let bundleID = frontmostBundleID.withLock { $0 }
        guard let rule = rules.withLock({ $0.rule(for: .mouseButton(number: number), in: bundleID) }) else { return false }
        if isDown { RuleActions.perform(rule.action) }
        return true
    }

    func respond(to press: KeyPress) -> Bool {
        guard press.kind == .keyDown, !press.isFromAnvil else { return false }
        let bundleID = frontmostBundleID.withLock { $0 }
        guard let rule = rules.withLock({ $0.rule(for: .shortcut(press.combo.keystroke), in: bundleID) }) else { return false }
        RuleActions.perform(rule.action)
        return true
    }
}
