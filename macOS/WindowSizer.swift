import AppKit
import WindowKit

enum WindowSizer {
    static func resizeFrontWindow(of pid: pid_t, to size: CGSize) {
        guard let window = AXUIElement.appWithShortTimeout(pid).focusedWindow,
              let frame = window.frame,
              let screen = NSScreen.holding(frame)
        else { return }
        window.move(to: CGRect(origin: frame.origin, size: size).kept(inside: screen.visibleFrameWithTopAtMinY))
    }
}
