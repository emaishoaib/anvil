import CoreGraphics
import Testing
@testable import WindowKit

struct ZoneChoiceTests {
    let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)

    func action(_ choice: ZoneChoice, in zone: SnapZone, at point: CGPoint, previous: WindowAction? = nil) -> WindowAction? {
        zone.action(for: choice, at: point, on: screen, previous: previous)
    }

    @Test func aSideEdgeSnapsToTheTopOrBottomHalfNearItsCorners() {
        #expect(action(.halfWithTopOrBottomNearCorners, in: .left, at: CGPoint(x: 0, y: 100)) == .topHalf)
        #expect(action(.halfWithTopOrBottomNearCorners, in: .right, at: CGPoint(x: 1439, y: 850)) == .bottomHalf)
        #expect(action(.halfWithTopOrBottomNearCorners, in: .right, at: CGPoint(x: 1439, y: 450)) == .rightHalf)
    }

    @Test func draggingFromAnOuterThirdTowardTheCenterSnapsToTwoThirds() {
        let middle = CGPoint(x: 720, y: 899)
        #expect(action(.thirdsWithTwoThirdsTowardCenter, in: .bottom, at: middle, previous: .firstThird) == .firstTwoThirds)
        #expect(action(.thirdsWithTwoThirdsTowardCenter, in: .bottom, at: middle, previous: .lastThird) == .lastTwoThirds)
        #expect(action(.thirdsWithTwoThirdsTowardCenter, in: .bottom, at: middle, previous: .firstTwoThirds) == .firstTwoThirds)
        #expect(action(.thirdsWithTwoThirdsTowardCenter, in: .bottom, at: middle) == .centerThird)
    }

    @Test func aZoneSetToNothingSnapsNowhere() {
        #expect(action(.nothing, in: .top, at: CGPoint(x: 720, y: 0)) == nil)
    }

    @Test func aPlainActionChoiceAlwaysGivesThatAction() {
        #expect(action(.action(.almostMaximize), in: .top, at: CGPoint(x: 720, y: 0)) == .almostMaximize)
    }

    @Test func onlyTheMatchingEdgesOfferTheSpecialChoices() {
        #expect(SnapZone.left.choices.contains(.halfWithTopOrBottomNearCorners))
        #expect(!SnapZone.top.choices.contains(.halfWithTopOrBottomNearCorners))
        #expect(SnapZone.bottom.choices.contains(.thirdsWithTwoThirdsTowardCenter))
        #expect(!SnapZone.topLeft.choices.contains(.thirdsWithTwoThirdsTowardCenter))
    }

    @Test func everyChoiceSurvivesBeingSavedAsText() {
        for zone in SnapZone.allCases {
            for choice in zone.choices {
                #expect(ZoneChoice(rawValue: choice.rawValue) == choice)
            }
        }
    }

    @Test func everyZoneOffersItsOwnDefault() {
        for zone in SnapZone.allCases {
            #expect(zone.choices.contains(zone.defaultChoice))
        }
    }
}
