import AppKit

/// The strike the menu bar icon plays over and over while Anvil works in the background. It waits a moment before the first strike, so work that ends quickly never shows, and once the work stops it lets the strike in progress finish rather than cutting it off. It is skipped when Reduce Motion is on.
final class StrikeLoop {
    private enum Phase {
        case idle
        case waiting(Task<Void, Never>)
        case striking(since: CFTimeInterval)
        case finishing(since: CFTimeInterval)
    }

    private static let startDelay = Duration.milliseconds(300)

    private let button: NSStatusBarButton
    private var phase = Phase.idle

    init(on button: NSStatusBarButton) {
        self.button = button
    }

    /// Whether a strike is playing over and over, including the last one finishing.
    var isStriking: Bool {
        switch phase {
        case .striking, .finishing: true
        case .idle, .waiting: false
        }
    }

    func set(_ isWorking: Bool) {
        switch (isWorking, phase) {
        case (true, .idle):
            guard !PanelAnimation.isReduced else { return }
            phase = .waiting(Task { await start() })
        case (true, .finishing(let since)):
            phase = .striking(since: since)
        case (false, .waiting(let task)):
            task.cancel()
            phase = .idle
        case (false, .striking(let since)):
            phase = .finishing(since: since)
            Task { await finish(strikingSince: since) }
        case (true, .waiting), (true, .striking), (false, .idle), (false, .finishing):
            return
        }
    }

    private func start() async {
        try? await Task.sleep(for: Self.startDelay)
        guard !Task.isCancelled else { return }
        phase = .striking(since: CACurrentMediaTime())
        StrikeAnimation.play(on: button, repeating: true)
    }

    /// Stops at the end of the strike in progress, unless the work started again meanwhile.
    private func finish(strikingSince since: CFTimeInterval) async {
        let played = CACurrentMediaTime() - since
        let left = StrikeAnimation.repeatSeconds - played.truncatingRemainder(dividingBy: StrikeAnimation.repeatSeconds)
        try? await Task.sleep(for: .seconds(left))
        guard case .finishing = phase else { return }
        StrikeAnimation.stop(on: button)
        phase = .idle
    }
}
