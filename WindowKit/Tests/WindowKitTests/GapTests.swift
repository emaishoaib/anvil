import CoreGraphics
import Testing
@testable import WindowKit

struct GapTests {
    let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
    let window = CGRect(x: 100, y: 100, width: 800, height: 600)

    @Test func halvesKeepTheGapFromTheScreenEdgesAndFromEachOther() {
        let left = WindowAction.leftHalf.frame(from: window, in: screen, gap: 10)
        let right = WindowAction.rightHalf.frame(from: window, in: screen, gap: 10)
        #expect(left == CGRect(x: 10, y: 10, width: 705, height: 880))
        #expect(right == CGRect(x: 725, y: 10, width: 705, height: 880))
    }

    @Test func maximizeKeepsTheGapOnEverySide() {
        #expect(WindowAction.maximize.frame(from: window, in: screen, gap: 10) == CGRect(x: 10, y: 10, width: 1420, height: 880))
    }

    @Test func anOddGapStillGivesWholeNumbersAndTheExactGap() {
        let first = WindowAction.firstThird.frame(from: window, in: screen, gap: 5)
        let center = WindowAction.centerThird.frame(from: window, in: screen, gap: 5)
        #expect(first == first.integral)
        #expect(center == center.integral)
        #expect(center.minX - first.maxX == 5)
        #expect(first.minX == 5)
    }

    @Test func movingToAnEdgeStopsAtTheGap() {
        #expect(WindowAction.moveLeft.frame(from: window, in: screen, gap: 10).minX == 10)
        #expect(WindowAction.moveDown.frame(from: window, in: screen, gap: 10).maxY == 890)
    }

    @Test func maximizeHeightKeepsTheGapAboveAndBelow() {
        #expect(WindowAction.maximizeHeight.frame(from: window, in: screen, gap: 10) == CGRect(x: 100, y: 10, width: 800, height: 880))
    }
}
