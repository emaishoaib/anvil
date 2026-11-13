public struct SmoothScroll: Sendable {
    private struct Tick: Sendable {
        let seconds: Double
        let direction: Int
    }

    public var settings: ScrollSettings
    private var impulses: [ScrollImpulse] = []
    private var lastTick: Tick?
    private var settledPoints = 0.0
    private var sentPoints = 0

    public init(settings: ScrollSettings) {
        self.settings = settings
    }

    public var isScrolling: Bool { !impulses.isEmpty }

    public mutating func add(ticks: Int, atSeconds time: Double, gain: Double = 1) {
        guard ticks != 0 else { return }
        let direction = ticks.signum()
        let sameDirection = lastTick?.direction == direction
        if !sameDirection { stop() }
        let interval = sameDirection ? lastTick.map { time - $0.seconds } : nil
        lastTick = Tick(seconds: time, direction: direction)
        let points = Double(ticks) * settings.pointsPerTick * gain * settings.boost(afterSeconds: interval)
        impulses.append(ScrollImpulse(
            startSeconds: time,
            points: points,
            durationSeconds: settings.durationSeconds,
            brakeSeconds: settings.brakeSeconds
        ))
    }

    public mutating func points(atSeconds time: Double) -> Int {
        let exact = settledPoints + impulses.map { $0.position(atSeconds: time) }.reduce(0, +)
        settledPoints += impulses.filter { time >= $0.endSeconds }.map(\.points).reduce(0, +)
        impulses.removeAll { time >= $0.endSeconds }
        let whole = Int(exact.rounded(.towardZero))
        let points = whole - sentPoints
        sentPoints = whole
        if impulses.isEmpty { forgetSentPoints() }
        return points
    }

    private mutating func stop() {
        impulses.removeAll()
        settledPoints = 0
        sentPoints = 0
    }

    private mutating func forgetSentPoints() {
        settledPoints -= Double(sentPoints)
        sentPoints = 0
    }
}
