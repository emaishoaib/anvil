import AppKit
import MouseKit

nonisolated enum ScrollAxis {
    case vertical, horizontal
}

final class SmoothScroller: NSObject {
    static let shared = SmoothScroller()

    private var vertical = SmoothScroll(settings: ScrollingSettings.defaults)
    private var horizontal = SmoothScroll(settings: ScrollingSettings.defaults)
    private var displayLink: CADisplayLink?

    private var isScrolling: Bool { vertical.isScrolling || horizontal.isScrolling }

    func add(ticks: Int, along axis: ScrollAxis, gain: Double, atSeconds time: Double) {
        let isStarting = displayLink == nil
        if isStarting {
            vertical.settings = ScrollingSettings.current
            horizontal.settings = ScrollingSettings.current
        }
        switch axis {
        case .vertical: vertical.add(ticks: ticks, atSeconds: time, gain: gain)
        case .horizontal: horizontal.add(ticks: ticks, atSeconds: time, gain: gain)
        }
        if isStarting { startFrames() }
    }

    private func startFrames() {
        let pointer = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(pointer) }) ?? NSScreen.main else { return }
        let link = screen.displayLink(target: self, selector: #selector(frame(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func frame(_ link: CADisplayLink) {
        let down = vertical.points(atSeconds: link.targetTimestamp)
        let across = horizontal.points(atSeconds: link.targetTimestamp)
        if down != 0 || across != 0 { send(down: down, across: across) }
        guard !isScrolling else { return }
        link.invalidate()
        displayLink = nil
    }

    private func send(down: Int, across: Int) {
        guard let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: Int32(clamping: down),
            wheel2: Int32(clamping: across),
            wheel3: 0
        ) else { return }
        event.flags = []
        event.setIntegerValueField(.eventSourceUserData, value: KeySender.marker)
        event.post(tap: .cghidEventTap)
    }
}
