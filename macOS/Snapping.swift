import AppKit
import WindowKit

final class Snapping {
    static let shared = Snapping()

    private var repeatedSnaps = RepeatedSnaps()
    private var restoreFrames = RestoreFrames()

    func snapFocusedWindow(to action: WindowAction) {
        guard let focused = Self.focusedWindow(), let screen = NSScreen.holding(focused.frame) else { return }
        let repeats = repeatedSnaps.repeats(of: action, on: focused.id, at: focused.frame)
        focused.element.move(to: action.frame(from: focused.frame, in: screen.visibleFrameWithTopAtMinY, repeats: repeats))
        let landedAt = focused.element.frame ?? focused.frame
        repeatedSnaps.record(action, on: focused.id, repeats: repeats, landedAt: landedAt)
        restoreFrames.recordSnap(of: focused.id, from: focused.frame, landedAt: landedAt)
    }

    func restoreFocusedWindow() {
        guard let focused = Self.focusedWindow(), let beforeFirstSnap = restoreFrames.takeFrame(for: focused.id) else { return }
        focused.element.move(to: beforeFirstSnap)
    }

    private static func focusedWindow() -> (element: AXUIElement, id: CGWindowID, frame: CGRect)? {
        guard let pid = NSWorkspace.shared.frontmostPID,
              let element = AXUIElement.appWithShortTimeout(pid).focusedWindow,
              let id = element.windowID,
              let frame = element.frame
        else { return nil }
        return (element, id, frame)
    }
}
