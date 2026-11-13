import Testing
@testable import MouseKit

struct SmoothScrollTests {
    let settings = ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0)

    func framePoints(_ scroll: inout SmoothScroll, framesPerSecond: Double, frames: ClosedRange<Int>) -> [Int] {
        frames.map { scroll.points(atSeconds: Double($0) / framesPerSecond) }
    }

    @Test func aTickScrollsItsWholeDistanceByTheEndOfTheDuration() {
        var scroll = SmoothScroll(settings: settings)
        scroll.add(ticks: 1, atSeconds: 0)
        #expect(framePoints(&scroll, framesPerSecond: 60, frames: 1...60).reduce(0, +) == 90)
    }

    @Test func aScrollCoversTheSameDistanceAtSixtyAndOneHundredTwentyHertz() {
        var atSixty = SmoothScroll(settings: settings)
        var atOneTwenty = SmoothScroll(settings: settings)
        atSixty.add(ticks: 1, atSeconds: 0)
        atOneTwenty.add(ticks: 1, atSeconds: 0)
        let sixty = framePoints(&atSixty, framesPerSecond: 60, frames: 1...6).reduce(0, +)
        let oneTwenty = framePoints(&atOneTwenty, framesPerSecond: 120, frames: 1...12).reduce(0, +)
        #expect(sixty == oneTwenty)
    }

    @Test func theScrollEndsAfterItsDurationAtAnyRefreshRate() {
        for framesPerSecond in [60.0, 120.0] {
            var scroll = SmoothScroll(settings: settings)
            scroll.add(ticks: 1, atSeconds: 0)
            let lastFrame = Int(framesPerSecond * 0.2)
            _ = framePoints(&scroll, framesPerSecond: framesPerSecond, frames: 1...(lastFrame - 1))
            #expect(scroll.isScrolling)
            _ = scroll.points(atSeconds: Double(lastFrame) / framesPerSecond)
            #expect(!scroll.isScrolling)
        }
    }

    @Test func ticksInTheSameDirectionAddUp() {
        var scroll = SmoothScroll(settings: settings)
        scroll.add(ticks: 1, atSeconds: 0)
        scroll.add(ticks: 2, atSeconds: 0.5)
        #expect(framePoints(&scroll, framesPerSecond: 60, frames: 1...60).reduce(0, +) == 270)
    }

    @Test func aTickTheOtherWayStopsTheScrollStillRunning() {
        var scroll = SmoothScroll(settings: settings)
        scroll.add(ticks: 1, atSeconds: 0)
        let before = framePoints(&scroll, framesPerSecond: 60, frames: 1...3).reduce(0, +)
        scroll.add(ticks: -1, atSeconds: 3.0 / 60)
        let after = framePoints(&scroll, framesPerSecond: 60, frames: 4...60).reduce(0, +)
        #expect(before == 33)
        #expect(after == -90)
    }

    @Test func twoQuickTicksScrollFurtherThanTwoSlowOnes() {
        let accelerated = ScrollSettings(durationFrames: 12, brakeFrame: 4, pointsPerTick: 90, acceleration: 0.4)
        var quick = SmoothScroll(settings: accelerated)
        var slow = SmoothScroll(settings: accelerated)
        quick.add(ticks: 1, atSeconds: 0)
        quick.add(ticks: 1, atSeconds: 0.05)
        slow.add(ticks: 1, atSeconds: 0)
        slow.add(ticks: 1, atSeconds: 0.5)
        let quickTotal = framePoints(&quick, framesPerSecond: 60, frames: 1...60).reduce(0, +)
        let slowTotal = framePoints(&slow, framesPerSecond: 60, frames: 1...60).reduce(0, +)
        #expect(slowTotal == 180)
        #expect(quickTotal > slowTotal)
    }
}
