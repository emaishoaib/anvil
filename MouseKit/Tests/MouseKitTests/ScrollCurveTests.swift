import Testing
@testable import MouseKit

struct ScrollCurveTests {
    func frameDistances(durationFrames: Int, brakeFrame: Int) -> [Double] {
        let settings = ScrollSettings(durationFrames: durationFrames, brakeFrame: brakeFrame, pointsPerTick: 90, acceleration: 0)
        let impulse = ScrollImpulse(startSeconds: 0, points: 90, durationSeconds: settings.durationSeconds, brakeSeconds: settings.brakeSeconds)
        let positions = (0...durationFrames).map { impulse.position(atSeconds: Double($0) / ScrollSettings.framesPerSecond) }
        return zip(positions, positions.dropFirst()).map { $1 - $0 }
    }

    @Test func theSpeedStaysEvenUntilTheBrakePointThenFallsAway() {
        let distances = frameDistances(durationFrames: 12, brakeFrame: 4)
        let beforeBrake = distances.prefix(4)
        let afterBrake = Array(distances.dropFirst(4))
        #expect(beforeBrake.allSatisfy { abs($0 - 11.25) < 1e-9 })
        #expect(zip(afterBrake, afterBrake.dropFirst()).allSatisfy { $0 > $1 })
    }

    @Test func aBrakePointAtTheEndKeepsTheSpeedEvenThroughout() {
        #expect(frameDistances(durationFrames: 12, brakeFrame: 12).allSatisfy { abs($0 - 7.5) < 1e-9 })
    }

    @Test func aBrakePointPastTheEndActsLikeOneAtTheEnd() {
        #expect(frameDistances(durationFrames: 12, brakeFrame: 40) == frameDistances(durationFrames: 12, brakeFrame: 12))
    }

    @Test func aFirstTickIsNotAccelerated() {
        #expect(ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0.4).boost(afterSeconds: nil) == 1)
    }

    @Test func slowTicksAreNotAccelerated() {
        #expect(ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0.4).boost(afterSeconds: 0.2) == 1)
    }

    @Test func fastTicksAreAcceleratedMoreTheFasterTheyCome() {
        let settings = ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0.4)
        #expect(settings.boost(afterSeconds: 0.05) > 1)
        #expect(settings.boost(afterSeconds: 0.02) > settings.boost(afterSeconds: 0.05))
    }

    @Test func noAccelerationNeverBoosts() {
        #expect(ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0).boost(afterSeconds: 0.01) == 1)
    }

    @Test func theBoostHasACeiling() {
        #expect(ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 10).boost(afterSeconds: 0) == ScrollSettings.maximumBoost)
    }
}
