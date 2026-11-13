import CoreGraphics
import Testing
@testable import WindowKit

struct WholeScreenActionTests {
    let screen = CGRect(x: 0, y: 25, width: 1440, height: 875)
    let window = CGRect(x: 100, y: 125, width: 800, height: 600)

    @Test func maximizeFillsTheWholeScreen() {
        #expect(WindowAction.maximize.frame(from: window, in: screen) == screen)
    }

    @Test func almostMaximizeLeavesAMarginOfAOneTwentiethOnEachSide() {
        #expect(WindowAction.almostMaximize.frame(from: window, in: screen) == CGRect(x: 72, y: 69, width: 1296, height: 787))
    }

    @Test func maximizeHeightKeepsTheWindowsLeftEdgeAndWidth() {
        #expect(WindowAction.maximizeHeight.frame(from: window, in: screen) == CGRect(x: 100, y: 25, width: 800, height: 875))
    }

    @Test func centerKeepsTheWindowsSizeAndMovesItToTheMiddle() {
        #expect(WindowAction.center.frame(from: window, in: screen) == CGRect(x: 320, y: 163, width: 800, height: 600))
    }

    @Test func centerShrinksAWindowThatIsBiggerThanTheScreen() {
        let hugeWindow = CGRect(x: 0, y: 0, width: 2000, height: 1200)
        #expect(WindowAction.center.frame(from: hugeWindow, in: screen) == screen)
    }
}
