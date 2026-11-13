import AppKit
import WindowKit

final class Snapping {
    static let shared = Snapping()

    private var repeatedSnaps = RepeatedSnaps()

    func snapFocusedWindow(to action: WindowAction) {
        guard let pid = NSWorkspace.shared.frontmostPID,
              let window = AXUIElement.appWithShortTimeout(pid).focusedWindow,
              let id = window.windowID,
              let frame = window.frame,
              let screen = NSScreen.holding(frame)
        else { return }
        let repeats = repeatedSnaps.repeats(of: action, on: id, at: frame)
        window.move(to: action.frame(from: frame, in: screen.visibleFrameWithTopAtMinY, repeats: repeats))
        repeatedSnaps.record(action, on: id, repeats: repeats, landedAt: window.frame ?? frame)
    }
}
