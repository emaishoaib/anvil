import CoreGraphics
import Testing
@testable import WindowKit

struct SizeCycleTests {
    let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
    let window = CGRect(x: 100, y: 100, width: 800, height: 600)

    @Test func leftHalfCyclesFromAHalfToTwoThirdsToAThirdAndBack() {
        let widths = (0...3).map { WindowAction.leftHalf.frame(from: window, in: screen, repeats: $0).width }
        #expect(widths == [720, 960, 480, 720])
    }

    @Test func rightHalfStaysAgainstTheRightEdgeAsItCycles() {
        #expect(WindowAction.rightHalf.frame(from: window, in: screen, repeats: 1) == CGRect(x: 480, y: 0, width: 960, height: 900))
        #expect(WindowAction.rightHalf.frame(from: window, in: screen, repeats: 2) == CGRect(x: 960, y: 0, width: 480, height: 900))
    }

    @Test func bottomHalfCyclesItsHeightAndStaysAtTheBottom() {
        #expect(WindowAction.bottomHalf.frame(from: window, in: screen, repeats: 1) == CGRect(x: 0, y: 300, width: 1440, height: 600))
    }

    @Test func cornersStayTheSameWhenRepeated() {
        #expect(WindowAction.topLeft.frame(from: window, in: screen, repeats: 1) == WindowAction.topLeft.frame(from: window, in: screen))
    }
}

struct RepeatedSnapsTests {
    let landed = CGRect(x: 0, y: 0, width: 720, height: 900)

    @Test func aFirstSnapHasNoRepeats() {
        #expect(RepeatedSnaps().repeats(of: .leftHalf, on: 1, at: landed) == 0)
    }

    @Test func snappingTheSameWindowAgainWhereItLandedCountsARepeat() {
        var snaps = RepeatedSnaps()
        snaps.record(.leftHalf, on: 1, repeats: 0, landedAt: landed)
        #expect(snaps.repeats(of: .leftHalf, on: 1, at: landed) == 1)
    }

    @Test func aDifferentActionStartsOver() {
        var snaps = RepeatedSnaps()
        snaps.record(.leftHalf, on: 1, repeats: 0, landedAt: landed)
        #expect(snaps.repeats(of: .rightHalf, on: 1, at: landed) == 0)
    }

    @Test func aDifferentWindowStartsOver() {
        var snaps = RepeatedSnaps()
        snaps.record(.leftHalf, on: 1, repeats: 0, landedAt: landed)
        #expect(snaps.repeats(of: .leftHalf, on: 2, at: landed) == 0)
    }

    @Test func aWindowMovedSinceItsLastSnapStartsOver() {
        var snaps = RepeatedSnaps()
        snaps.record(.leftHalf, on: 1, repeats: 0, landedAt: landed)
        #expect(snaps.repeats(of: .leftHalf, on: 1, at: landed.offsetBy(dx: 10, dy: 0)) == 0)
    }
}
