import AppKit
import WindowKit

final class Snapping {
    static let shared = Snapping()

    private var repeatedSnaps = RepeatedSnaps()
    private var restoreFrames = RestoreFrames()

    func snapFocusedWindow(to action: WindowAction) {
        guard let focused = Self.focusedWindow(), let screen = NSScreen.holding(focused.frame) else { return }
        let repeats = repeatedSnaps.repeats(of: action, on: focused.id, at: focused.frame)
        snap(focused.element, id: focused.id, from: focused.frame, to: action, in: screen.visibleFrameWithTopAtMinY, repeats: repeats)
    }

    func snap(_ window: DraggedWindow, to action: WindowAction, in area: CGRect) {
        snap(window.element, id: window.id, from: window.frameBeforeDrag, to: action, in: area, repeats: 0)
    }

    func restoreFocusedWindow() {
        guard let focused = Self.focusedWindow(), let beforeFirstSnap = restoreFrames.takeFrame(for: focused.id) else { return }
        focused.element.move(to: beforeFirstSnap)
    }

    private func snap(_ element: AXUIElement, id: CGWindowID, from frame: CGRect, to action: WindowAction, in area: CGRect, repeats: Int) {
        element.move(to: action.frame(from: frame, in: area, repeats: repeats, gap: SnappingSettings.gap))
        let landedAt = element.frame ?? frame
        repeatedSnaps.record(action, on: id, repeats: repeats, landedAt: landedAt)
        restoreFrames.recordSnap(of: id, from: frame, landedAt: landedAt)
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
