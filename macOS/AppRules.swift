import AppKit
import RulesKit

enum AppRules {
    static func start() {
        NSWorkspace.shared.onAppChange(NSWorkspace.didLaunchApplicationNotification) { pid in
            run(.appOpens, for: pid)
        }
        NSWorkspace.shared.onAppChange(NSWorkspace.didActivateApplicationNotification) { pid in
            run(.appComesToFront, for: pid)
        }
    }

    private static func run(_ trigger: RuleTrigger, for pid: pid_t) {
        guard Tool.rules.isOn,
              let bundleID = NSRunningApplication(processIdentifier: pid)?.bundleIdentifier,
              let rule = RuleLibrary.shared.rules.rule(for: trigger, in: bundleID)
        else { return }
        RuleActions.perform(rule.action, for: pid)
    }
}
