import AppKit
import WindowKit

final class DragSnapping {
    static let shared = DragSnapping()

    private static let giveUpDistancePoints: CGFloat = 20

    private struct Target: Equatable {
        let action: WindowAction
        let area: CGRect
    }

    private enum State {
        case idle
        case pressed(DraggedWindow)
        case moving(DraggedWindow, target: Target?)
    }

    private let footprint = Footprint()
    private var state = State.idle

    private var pointer: CGPoint { CGEvent(source: nil)?.location ?? .zero }

    func start() {
        _ = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]) { event in
            let type = event.type
            MainActor.assumeIsolated { DragSnapping.shared.handle(type) }
        }
    }

    private func handle(_ type: NSEvent.EventType) {
        switch type {
        case .leftMouseDown: pressed()
        case .leftMouseDragged: dragged()
        default: released()
        }
    }

    private func pressed() {
        guard Tool.windows.isOn, SnappingSettings.snapsByDragging || SnappingSettings.restoresSizeWhenUnsnapped,
              let window = DraggedWindow(under: NSEvent.mouseLocation, pointer: pointer)
        else { return state = .idle }
        state = .pressed(window)
    }

    private func dragged() {
        switch state {
        case .idle:
            return
        case .pressed(let window):
            guard let frame = window.liveFrame, frame.size == window.frameBeforeSnap.size else { return state = .idle }
            if frame.origin != window.frameBeforeSnap.origin { return follow(Snapping.shared.unsnap(window, under: pointer), from: nil) }
            if hypot(pointer.x - window.pointerAtPress.x, pointer.y - window.pointerAtPress.y) > Self.giveUpDistancePoints { state = .idle }
        case .moving(let window, let target):
            follow(window, from: target)
        }
    }

    private func follow(_ window: DraggedWindow, from previous: Target?) {
        let target = Self.target(at: pointer, after: previous?.action)
        state = .moving(window, target: target)
        guard target != previous else { return }
        guard let target else { return footprint.hide() }
        footprint.show(target.action.frame(from: window.frameBeforeSnap, in: target.area, gap: SnappingSettings.gap))
    }

    private func released() {
        if case .moving(let window, let target?) = state {
            Snapping.shared.snap(window, to: target.action, in: target.area)
        }
        footprint.hide()
        state = .idle
    }

    private static func target(at point: CGPoint, after previous: WindowAction?) -> Target? {
        guard SnappingSettings.snapsByDragging,
              let screen = NSScreen.under(point),
              let zone = SnapZone(at: point, on: screen.frameWithTopAtMinY),
              let action = zone.action(for: SnappingSettings.choice(for: zone), at: point, on: screen.frameWithTopAtMinY, previous: previous)
        else { return nil }
        return Target(action: action, area: screen.visibleFrameWithTopAtMinY)
    }
}
