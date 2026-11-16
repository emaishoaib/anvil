import AppKit

/// The glow the menu bar icon plays while Anvil works in the background: the anvil itself warms to orange and cools back, over and over. Each tick swaps in a copy of the icon filled with the blended colour, since the menu bar ignores a tint on its icons, and the usual icon comes back once it has cooled. Replacing the icon, rather than laying an orange copy over it, keeps its edges clean. It waits a moment before the first warming, so work that ends quickly never shows. Once it has started, it always plays at least one full warming and cooling, so short work still reads as a glow, and after that it eases back to the usual colour when the work stops. A timer drives it only while it plays, and it is skipped when Reduce Motion is on.
final class HeatAnimation {
    private enum Phase {
        case idle
        case heating(since: CFTimeInterval)
        case finishingFirstCycle(since: CFTimeInterval)
        case cooling(from: CGFloat, since: CFTimeInterval)
    }

    private static let cycleSeconds = 1.6
    private static let startDelaySeconds = 0.3
    private static let coolSeconds = 0.3
    private static let tickSeconds = 1.0 / 30

    private let button: NSStatusBarButton
    private let icon: NSImage?
    private var phase = Phase.idle
    private var heat: CGFloat = 0
    private var timer: Timer?

    init(on button: NSStatusBarButton) {
        self.button = button
        icon = button.image
    }

    func set(_ isHot: Bool) {
        let now = CACurrentMediaTime()
        switch (isHot, phase) {
        case (true, .heating), (false, .idle), (false, .finishingFirstCycle), (false, .cooling):
            return
        case (true, .finishingFirstCycle(let since)):
            phase = .heating(since: since)
        case (true, _):
            guard !PanelAnimation.isReduced else { return }
            phase = .heating(since: now)
        case (false, .heating(let since)):
            phase = stopping(heatingSince: since, at: now)
        }
        startTicking()
    }

    /// Where the glow goes when the work stops: nowhere if it has not shown yet, through the rest of its first cycle if it is still in it, so it is never cut to a flicker, and otherwise into cooling.
    private func stopping(heatingSince since: CFTimeInterval, at now: CFTimeInterval) -> Phase {
        let seconds = now - since - Self.startDelaySeconds
        if seconds <= 0 { return .idle }
        if seconds < Self.cycleSeconds { return .finishingFirstCycle(since: since) }
        return .cooling(from: heat, since: now)
    }

    private func startTicking() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: Self.tickSeconds, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        let now = CACurrentMediaTime()
        if case .cooling(_, let since) = phase, now - since >= Self.coolSeconds { phase = .idle }
        if case .finishingFirstCycle(let since) = phase, now - since - Self.startDelaySeconds >= Self.cycleSeconds { phase = .idle }
        heat = heat(at: now)
        paint()
        guard case .idle = phase else { return }
        timer?.invalidate()
        timer = nil
    }

    private func heat(at now: CFTimeInterval) -> CGFloat {
        switch phase {
        case .idle:
            return 0
        case .heating(let since), .finishingFirstCycle(let since):
            let seconds = now - since - Self.startDelaySeconds
            guard seconds > 0 else { return 0 }
            return (1 - cos(2 * .pi * seconds / Self.cycleSeconds)) / 2
        case .cooling(let from, let since):
            let left = max(1 - (now - since) / Self.coolSeconds, 0)
            return from * left * left
        }
    }

    private func paint() {
        guard let icon else { return }
        guard heat > 0 else {
            button.image = icon
            return
        }
        var colour = NSColor.orange
        button.effectiveAppearance.performAsCurrentDrawingAppearance {
            let cool = NSColor.labelColor.usingColorSpace(.sRGB)
            let hot = NSColor.systemOrange.usingColorSpace(.sRGB) ?? .orange
            colour = cool?.blended(withFraction: heat, of: hot) ?? hot
        }
        button.image = Self.filled(icon, with: colour)
    }

    /// A copy of the icon in one solid colour, as an ordinary image the menu bar draws as it is.
    private static func filled(_ icon: NSImage, with colour: NSColor) -> NSImage {
        let image = NSImage(size: icon.size, flipped: false) { rect in
            icon.draw(in: rect)
            colour.set()
            rect.fill(using: .sourceAtop)
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = icon.accessibilityDescription
        return image
    }
}
