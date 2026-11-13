public struct ScrollSettings: Hashable, Codable, Sendable {
    public static let framesPerSecond = 60.0
    static let unacceleratedTicksPerSecond = 10.0
    static let shortestTickIntervalSeconds = 0.001
    static let maximumBoost = 8.0

    public var durationFrames: Int
    public var brakeFrame: Int
    public var pointsPerTick: Double
    public var acceleration: Double

    public init(durationFrames: Int, brakeFrame: Int, pointsPerTick: Double, acceleration: Double) {
        self.durationFrames = durationFrames
        self.brakeFrame = brakeFrame
        self.pointsPerTick = pointsPerTick
        self.acceleration = acceleration
    }

    var durationSeconds: Double {
        Double(max(durationFrames, 1)) / Self.framesPerSecond
    }

    var brakeSeconds: Double {
        Double(min(max(brakeFrame, 1), max(durationFrames, 1))) / Self.framesPerSecond
    }

    func boost(afterSeconds interval: Double?) -> Double {
        guard let interval, acceleration > 0 else { return 1 }
        let ticksPerSecond = 1 / max(interval, Self.shortestTickIntervalSeconds)
        let excess = max(0, ticksPerSecond / Self.unacceleratedTicksPerSecond - 1)
        return min(1 + acceleration * excess, Self.maximumBoost)
    }
}
