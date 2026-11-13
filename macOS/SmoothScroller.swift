import AppKit
import MouseKit

nonisolated enum WheelEffect {
    case scrollVertically, scrollHorizontally, zoom
}

final class SmoothScroller: NSObject {
    static let shared = SmoothScroller()

    private static let zoomPerClickThousandths = 100.0

    private var vertical = SmoothScroll(settings: ScrollingSettings.defaults)
    private var horizontal = SmoothScroll(settings: ScrollingSettings.defaults)
    private var zoom = SmoothScroll(settings: ScrollingSettings.defaults)
    private var isPinching = false
    private var displayLink: CADisplayLink?

    private var isScrolling: Bool { vertical.isScrolling || horizontal.isScrolling || zoom.isScrolling }

    func add(ticks: Int, for effect: WheelEffect, gain: Double, atSeconds time: Double) {
        let isStarting = displayLink == nil
        if isStarting { useCurrentSettings() }
        switch effect {
        case .scrollVertically: vertical.add(ticks: ticks, atSeconds: time, gain: gain)
        case .scrollHorizontally: horizontal.add(ticks: ticks, atSeconds: time, gain: gain)
        case .zoom: zoom.add(ticks: ticks, atSeconds: time, gain: gain)
        }
        if isStarting { startFrames() }
    }

    private func useCurrentSettings() {
        let settings = ScrollingSettings.current
        vertical.settings = settings
        horizontal.settings = settings
        zoom.settings = settings
        zoom.settings.pointsPerTick = Self.zoomPerClickThousandths
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
        pinch(zoom.points(atSeconds: link.targetTimestamp))
        guard !isScrolling else { return }
        link.invalidate()
        displayLink = nil
    }

    private func pinch(_ thousandths: Int) {
        if thousandths != 0 {
            if !isPinching { PinchSender.send(0, phase: .began) }
            isPinching = true
            PinchSender.send(Double(thousandths) / 1000, phase: .changed)
        }
        guard isPinching, !zoom.isScrolling else { return }
        PinchSender.send(0, phase: .ended)
        isPinching = false
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
