import AppKit
import os
import RulesKit

nonisolated final class RuleKeys: KeyResponder {
    static let shared = RuleKeys()

    private let rules = OSAllocatedUnfairLock(initialState: Rules())
    private let frontmostBundleID = OSAllocatedUnfairLock<String?>(initialState: nil)
    private let drag = OSAllocatedUnfairLock<ButtonDrag?>(initialState: nil)

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

    func respond(toMouse type: CGEventType, button number: Int, at location: CGPoint) -> Bool {
        switch type {
        case .otherMouseDown: pressed(number, at: location)
        case .otherMouseDragged: dragged(number, to: location)
        default: released(number, at: location)
        }
    }

    private func pressed(_ number: Int, at location: CGPoint) -> Bool {
        let bundleID = frontmostBundleID.withLock { $0 }
        guard rules.withLock({ $0.hasDragRules(forButton: number, in: bundleID) }) else {
            return perform(.mouseButton(number: number))
        }
        drag.withLock { $0 = ButtonDrag(button: number, across: location.x, down: location.y) }
        return true
    }

    private func dragged(_ number: Int, to location: CGPoint) -> Bool {
        guard drag.withLock({ $0?.button == number }) else { return false }
        if let direction = drag.withLock({ $0?.move(across: location.x, down: location.y) }) {
            perform(.mouseDrag(number: number, direction: direction))
        }
        return true
    }

    private func released(_ number: Int, at location: CGPoint) -> Bool {
        let finished = drag.withLock { current -> ButtonDrag? in
            guard let tracked = current, tracked.button == number else { return nil }
            current = nil
            return tracked
        }
        guard let finished else { return hasRule(for: .mouseButton(number: number)) }
        guard !finished.hasDragged, !perform(.mouseButton(number: number)) else { return true }
        ButtonClickSender.send(button: number, at: location)
        return true
    }

    private func hasRule(for trigger: RuleTrigger) -> Bool {
        let bundleID = frontmostBundleID.withLock { $0 }
        return rules.withLock { $0.rule(for: trigger, in: bundleID) } != nil
    }

    @discardableResult
    private func perform(_ trigger: RuleTrigger) -> Bool {
        let bundleID = frontmostBundleID.withLock { $0 }
        guard let rule = rules.withLock({ $0.rule(for: trigger, in: bundleID) }) else { return false }
        RuleActions.perform(rule.action)
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
