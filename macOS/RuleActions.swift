import AppKit
import RulesKit

nonisolated enum RuleActions {
    static func perform(_ action: RuleAction, for pid: pid_t? = nil) {
        switch action {
        case .sendShortcut(let keystroke): KeySender.send(KeyCombo(keystroke))
        case .chooseMenuItem(let path): DispatchQueue.main.async { MenuItems.choose(path) }
        case .playSound(let name): DispatchQueue.main.async { SystemSounds.play(name) }
        case .quitApp: DispatchQueue.main.async { pid.flatMap(NSRunningApplication.init)?.terminate() }
        }
    }
}
