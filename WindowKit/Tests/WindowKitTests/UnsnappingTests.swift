import CoreGraphics
import Testing
@testable import WindowKit

struct UnsnappingTests {
    let snapped = CGRect(x: 0, y: 0, width: 720, height: 900)
    let original = CGSize(width: 800, height: 600)

    @Test func theWindowTakesBackItsSizeAndKeepsItsTop() {
        let unsnapped = snapped.resized(to: original, keepingPointerAt: CGPoint(x: 360, y: 10))
        #expect(unsnapped.size == original)
        #expect(unsnapped.minY == 0)
    }

    @Test func thePointerStaysTheSameShareAcrossTheWindow() {
        let pointer = CGPoint(x: 180, y: 10)
        let unsnapped = snapped.resized(to: original, keepingPointerAt: pointer)
        #expect(unsnapped.minX == -20)
        #expect((pointer.x - unsnapped.minX) / unsnapped.width == 0.25)
    }
}
