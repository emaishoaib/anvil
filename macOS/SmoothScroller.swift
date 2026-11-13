import AppKit
import MouseKit

final class SmoothScroller: NSObject {
    static let shared = SmoothScroller()

    private static let settings = ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0.4)

    private var scroll = SmoothScroll(settings: settings)
    private var displayLink: CADisplayLink?

    func add(ticks: Int, atSeconds time: Double) {
        scroll.add(ticks: ticks, atSeconds: time)
        guard displayLink == nil else { return }
        startFrames()
    }

    private func startFrames() {
        let pointer = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(pointer) }) ?? NSScreen.main else { return }
        let link = screen.displayLink(target: self, selector: #selector(frame(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc private func frame(_ link: CADisplayLink) {
        let points = scroll.points(atSeconds: link.targetTimestamp)
        if points != 0 { send(points) }
        guard !scroll.isScrolling else { return }
        link.invalidate()
        displayLink = nil
    }

    private func send(_ points: Int) {
        guard let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: Int32(clamping: points), wheel2: 0, wheel3: 0)
        else { return }
        event.setIntegerValueField(.eventSourceUserData, value: KeySender.marker)
        event.post(tap: .cghidEventTap)
    }
}
