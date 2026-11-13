import CoreGraphics
import Testing
@testable import WindowKit

struct WindowActionTests {
    let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
    let window = CGRect(x: 100, y: 100, width: 800, height: 600)

    @Test func leftAndRightHalvesSplitTheScreenDownTheMiddle() {
        #expect(WindowAction.leftHalf.frame(from: window, in:screen) == CGRect(x: 0, y: 0, width: 720, height: 900))
        #expect(WindowAction.rightHalf.frame(from: window, in:screen) == CGRect(x: 720, y: 0, width: 720, height: 900))
    }

    @Test func centerHalfLeavesAQuarterOnEachSide() {
        #expect(WindowAction.centerHalf.frame(from: window, in:screen) == CGRect(x: 360, y: 0, width: 720, height: 900))
    }

    @Test func topHalfStartsAtTheSmallestY() {
        #expect(WindowAction.topHalf.frame(from: window, in:screen) == CGRect(x: 0, y: 0, width: 1440, height: 450))
        #expect(WindowAction.bottomHalf.frame(from: window, in:screen) == CGRect(x: 0, y: 450, width: 1440, height: 450))
    }

    @Test func cornersAreQuartersOfTheScreen() {
        #expect(WindowAction.topLeft.frame(from: window, in:screen) == CGRect(x: 0, y: 0, width: 720, height: 450))
        #expect(WindowAction.topRight.frame(from: window, in:screen) == CGRect(x: 720, y: 0, width: 720, height: 450))
        #expect(WindowAction.bottomLeft.frame(from: window, in:screen) == CGRect(x: 0, y: 450, width: 720, height: 450))
        #expect(WindowAction.bottomRight.frame(from: window, in:screen) == CGRect(x: 720, y: 450, width: 720, height: 450))
    }

    @Test func thirdsSplitTheWidthIntoThreeEqualColumns() {
        #expect(WindowAction.firstThird.frame(from: window, in:screen) == CGRect(x: 0, y: 0, width: 480, height: 900))
        #expect(WindowAction.centerThird.frame(from: window, in:screen) == CGRect(x: 480, y: 0, width: 480, height: 900))
        #expect(WindowAction.lastThird.frame(from: window, in:screen) == CGRect(x: 960, y: 0, width: 480, height: 900))
    }

    @Test func twoThirdsCoverTheFirstOrLastTwoColumns() {
        #expect(WindowAction.firstTwoThirds.frame(from: window, in:screen) == CGRect(x: 0, y: 0, width: 960, height: 900))
        #expect(WindowAction.lastTwoThirds.frame(from: window, in:screen) == CGRect(x: 480, y: 0, width: 960, height: 900))
    }

    @Test func neighbouringThirdsMeetWithoutAGapOnAnOddWidth() {
        let oddScreen = CGRect(x: 0, y: 0, width: 1511, height: 900)
        let first = WindowAction.firstThird.frame(from: window, in:oddScreen)
        let center = WindowAction.centerThird.frame(from: window, in:oddScreen)
        let last = WindowAction.lastThird.frame(from: window, in:oddScreen)
        #expect(first.maxX == center.minX)
        #expect(center.maxX == last.minX)
        #expect(last.maxX == oddScreen.maxX)
    }

    @Test func framesStayWholeNumbersOnAnOddSizedScreen() {
        let oddScreen = CGRect(x: 0, y: 0, width: 1511, height: 875)
        for action in WindowAction.allCases {
            let frame = action.frame(from: window, in:oddScreen)
            #expect(frame == frame.integral)
        }
    }

    @Test func framesFollowAScreenThatDoesNotStartAtZero() {
        let secondScreen = CGRect(x: 1440, y: 25, width: 1920, height: 1055)
        #expect(WindowAction.rightHalf.frame(from: window, in:secondScreen).origin == CGPoint(x: 2400, y: 25))
        #expect(WindowAction.bottomLeft.frame(from: window, in:secondScreen).maxY == secondScreen.maxY)
    }
}
