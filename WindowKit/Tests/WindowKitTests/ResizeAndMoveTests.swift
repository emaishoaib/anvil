import CoreGraphics
import Testing
@testable import WindowKit

struct ResizeAndMoveTests {
    let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
    let window = CGRect(x: 100, y: 100, width: 800, height: 600)

    @Test func makeLargerGrowsByThirtyPointsAroundTheMiddle() {
        #expect(WindowAction.makeLarger.frame(from: window, in: screen) == CGRect(x: 85, y: 85, width: 830, height: 630))
    }

    @Test func makeSmallerShrinksByThirtyPointsAroundTheMiddle() {
        #expect(WindowAction.makeSmaller.frame(from: window, in: screen) == CGRect(x: 115, y: 115, width: 770, height: 570))
    }

    @Test func makeSmallerStopsAtAQuarterOfTheScreen() {
        let smallWindow = CGRect(x: 500, y: 300, width: 370, height: 230)
        #expect(WindowAction.makeSmaller.frame(from: smallWindow, in: screen).size == CGSize(width: 360, height: 225))
    }

    @Test func makeLargerKeepsAWindowAtTheEdgeOnTheScreen() {
        let windowAtLeftEdge = CGRect(x: 0, y: 100, width: 800, height: 600)
        #expect(WindowAction.makeLarger.frame(from: windowAtLeftEdge, in: screen) == CGRect(x: 0, y: 85, width: 830, height: 630))
    }

    @Test func makeLargerStopsAtTheSizeOfTheScreen() {
        #expect(WindowAction.makeLarger.frame(from: screen, in: screen) == screen)
    }

    @Test func movingToAnEdgeKeepsTheWindowsSize() {
        #expect(WindowAction.moveLeft.frame(from: window, in: screen) == CGRect(x: 0, y: 100, width: 800, height: 600))
        #expect(WindowAction.moveRight.frame(from: window, in: screen) == CGRect(x: 640, y: 100, width: 800, height: 600))
        #expect(WindowAction.moveUp.frame(from: window, in: screen) == CGRect(x: 100, y: 0, width: 800, height: 600))
        #expect(WindowAction.moveDown.frame(from: window, in: screen) == CGRect(x: 100, y: 300, width: 800, height: 600))
    }

    @Test func movingAWindowBiggerThanTheScreenShrinksItToFit() {
        let hugeWindow = CGRect(x: -50, y: 0, width: 2000, height: 1200)
        #expect(WindowAction.moveLeft.frame(from: hugeWindow, in: screen) == screen)
    }
}
