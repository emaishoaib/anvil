import AppKit
import WindowKit

enum Snapping {
    static func snapFocusedWindow(to action: WindowAction) {
        guard let pid = NSWorkspace.shared.frontmostPID,
              let window = AXUIElement.appWithShortTimeout(pid).focusedWindow,
              let frame = window.frame,
              let screen = NSScreen.holding(frame)
        else { return }
        window.move(to: action.frame(from: frame, in: screen.visibleFrameWithTopAtMinY))
    }
}
