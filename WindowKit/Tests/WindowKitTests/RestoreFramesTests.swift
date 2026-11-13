import CoreGraphics
import Testing
@testable import WindowKit

struct RestoreFramesTests {
    let original = CGRect(x: 100, y: 100, width: 800, height: 600)
    let leftHalf = CGRect(x: 0, y: 0, width: 720, height: 900)
    let rightHalf = CGRect(x: 720, y: 0, width: 720, height: 900)

    @Test func aWindowNeverSnappedHasNothingToRestore() {
        var frames = RestoreFrames()
        #expect(frames.takeFrame(for: 1) == nil)
    }

    @Test func restoringGivesBackTheFrameFromBeforeTheSnap() {
        var frames = RestoreFrames()
        frames.recordSnap(of: 1, from: original, landedAt: leftHalf)
        #expect(frames.takeFrame(for: 1) == original)
    }

    @Test func snappingAgainWithoutMovingKeepsTheFrameFromBeforeTheFirstSnap() {
        var frames = RestoreFrames()
        frames.recordSnap(of: 1, from: original, landedAt: leftHalf)
        frames.recordSnap(of: 1, from: leftHalf, landedAt: rightHalf)
        #expect(frames.takeFrame(for: 1) == original)
    }

    @Test func movingTheWindowByHandBetweenSnapsSavesWhereItWasMoved() {
        let movedByHand = CGRect(x: 300, y: 200, width: 640, height: 480)
        var frames = RestoreFrames()
        frames.recordSnap(of: 1, from: original, landedAt: leftHalf)
        frames.recordSnap(of: 1, from: movedByHand, landedAt: rightHalf)
        #expect(frames.takeFrame(for: 1) == movedByHand)
    }

    @Test func eachWindowKeepsItsOwnFrame() {
        var frames = RestoreFrames()
        frames.recordSnap(of: 1, from: original, landedAt: leftHalf)
        frames.recordSnap(of: 2, from: leftHalf, landedAt: rightHalf)
        #expect(frames.takeFrame(for: 1) == original)
        #expect(frames.takeFrame(for: 2) == leftHalf)
    }

    @Test func restoringForgetsTheFrame() {
        var frames = RestoreFrames()
        frames.recordSnap(of: 1, from: original, landedAt: leftHalf)
        _ = frames.takeFrame(for: 1)
        #expect(frames.takeFrame(for: 1) == nil)
    }
}
