import AppKit
import RulesKit

nonisolated enum RuleActions {
    static func perform(_ action: RuleAction, for pid: pid_t? = nil) {
        switch action {
        case .sendShortcut(let keystroke): KeySender.send(KeyCombo(keystroke))
        case .chooseMenuItem(let path): DispatchQueue.main.async { MenuItems.choose(path) }
        case .playSound(let name): DispatchQueue.main.async { SystemSounds.play(name) }
        case .quitApp: DispatchQueue.main.async { pid.flatMap(NSRunningApplication.init)?.terminate() }
        case .swipe(let direction): SwipeSender.send(direction)
        case .playOrPauseMedia: DispatchQueue.main.async { MediaKeySender.playOrPause() }
        case .resizeWindow(let width, let height):
            guard let pid else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                WindowSizer.resizeFrontWindow(of: pid, to: CGSize(width: width, height: height))
            }
        }
    }
}
