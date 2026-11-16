import AppKit

/// The glow the menu bar icon plays while Anvil works in the background: the anvil itself warms to orange and cools back, over and over, by changing the colour the menu bar draws it in. Recolouring the icon, rather than laying an orange copy over it, keeps its edges clean. It waits a moment before the first warming, so work that ends quickly never shows, and it eases back to the usual colour when the work stops. A timer drives it only while it plays, and it is skipped when Reduce Motion is on.
final class HeatAnimation {
    private enum Phase {
        case idle
        case heating(since: CFTimeInterval)
        case cooling(from: CGFloat, since: CFTimeInterval)
    }

    private static let cycleSeconds = 1.6
    private static let startDelaySeconds = 0.3
    private static let coolSeconds = 0.3
    private static let tickSeconds = 1.0 / 30

    private let button: NSStatusBarButton
    private var phase = Phase.idle
    private var heat: CGFloat = 0
    private var timer: Timer?

    init(on button: NSStatusBarButton) {
        self.button = button
    }

    func set(_ isHot: Bool) {
        let now = CACurrentMediaTime()
        switch (isHot, phase) {
        case (true, .heating), (false, .idle), (false, .cooling):
            return
        case (true, _):
            guard !PanelAnimation.isReduced else { return }
            phase = .heating(since: now)
        case (false, .heating):
            phase = .cooling(from: heat, since: now)
        }
        startTicking()
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
        case .heating(let since):
            let seconds = now - since - Self.startDelaySeconds
            guard seconds > 0 else { return 0 }
            return (1 - cos(2 * .pi * seconds / Self.cycleSeconds)) / 2
        case .cooling(let from, let since):
            let left = max(1 - (now - since) / Self.coolSeconds, 0)
            return from * left * left
        }
    }

    private func paint() {
        guard heat > 0 else {
            button.contentTintColor = nil
            return
        }
        button.effectiveAppearance.performAsCurrentDrawingAppearance {
            let cool = NSColor.labelColor.usingColorSpace(.sRGB)
            let hot = NSColor.systemOrange.usingColorSpace(.sRGB) ?? .orange
            button.contentTintColor = cool?.blended(withFraction: heat, of: hot) ?? hot
        }
    }
}
