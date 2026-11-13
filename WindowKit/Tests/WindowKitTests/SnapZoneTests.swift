import CoreGraphics
import Testing
@testable import WindowKit

struct SnapZoneTests {
    let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)

    func action(at point: CGPoint, on screen: CGRect) -> WindowAction? {
        SnapZone(at: point, on: screen)?.action(at: point, on: screen)
    }

    @Test func aPointerAwayFromTheEdgesIsInNoZone() {
        #expect(SnapZone(at: CGPoint(x: 720, y: 450), on: screen) == nil)
        #expect(SnapZone(at: CGPoint(x: 6, y: 450), on: screen) == nil)
    }

    @Test func theSideEdgesSnapToHalves() {
        #expect(action(at: CGPoint(x: 0, y: 450), on: screen) == .leftHalf)
        #expect(action(at: CGPoint(x: 1439, y: 450), on: screen) == .rightHalf)
    }

    @Test func theTopEdgeMaximizes() {
        #expect(action(at: CGPoint(x: 720, y: 0), on: screen) == .maximize)
    }

    @Test func cornersReachTwentyPointsAlongEachEdge() {
        #expect(SnapZone(at: CGPoint(x: 0, y: 10), on: screen) == .topLeft)
        #expect(SnapZone(at: CGPoint(x: 15, y: 0), on: screen) == .topLeft)
        #expect(SnapZone(at: CGPoint(x: 1439, y: 899), on: screen) == .bottomRight)
        #expect(SnapZone(at: CGPoint(x: 0, y: 30), on: screen) == .left)
    }

    @Test func cornersSnapToTheirQuarter() {
        #expect(action(at: CGPoint(x: 1439, y: 0), on: screen) == .topRight)
        #expect(action(at: CGPoint(x: 0, y: 899), on: screen) == .bottomLeft)
    }

    @Test func theBottomEdgeSnapsToTheThirdUnderThePointer() {
        #expect(action(at: CGPoint(x: 100, y: 899), on: screen) == .firstThird)
        #expect(action(at: CGPoint(x: 720, y: 899), on: screen) == .centerThird)
        #expect(action(at: CGPoint(x: 1400, y: 899), on: screen) == .lastThird)
    }

    @Test func zonesFollowAScreenThatDoesNotStartAtZero() {
        let secondScreen = CGRect(x: 1440, y: 0, width: 1920, height: 1080)
        #expect(action(at: CGPoint(x: 1440, y: 500), on: secondScreen) == .leftHalf)
        #expect(action(at: CGPoint(x: 1500, y: 1079), on: secondScreen) == .firstThird)
    }
}
