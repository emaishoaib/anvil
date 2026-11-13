import Foundation
import Testing
@testable import RulesKit

struct ButtonDragTests {
    @Test func aSmallMoveIsStillAClick() {
        var drag = ButtonDrag(button: 6, across: 100, down: 100)
        #expect(drag.move(across: 110, down: 115) == nil)
        #expect(!drag.hasDragged)
    }

    @Test func aDragGoesTheWayItMovedMost() {
        var up = ButtonDrag(button: 6, across: 100, down: 100)
        var down = ButtonDrag(button: 6, across: 100, down: 100)
        var left = ButtonDrag(button: 6, across: 100, down: 100)
        var right = ButtonDrag(button: 6, across: 100, down: 100)
        #expect(up.move(across: 110, down: 50) == .up)
        #expect(down.move(across: 90, down: 150) == .down)
        #expect(left.move(across: 50, down: 110) == .left)
        #expect(right.move(across: 150, down: 90) == .right)
    }

    @Test func aDragFiresOnlyOncePerPress() {
        var drag = ButtonDrag(button: 6, across: 0, down: 0)
        #expect(drag.move(across: 0, down: 40) == .down)
        #expect(drag.move(across: 0, down: 200) == nil)
        #expect(drag.hasDragged)
    }

    @Test func dragRulesAreFoundOnlyForTheirButtonAndApps() {
        let obsidian = "md.obsidian"
        let rules = Rules([
            Rule(trigger: .mouseDrag(number: 6, direction: .down), apps: .only(bundleIDs: [obsidian]), action: .playOrPauseMedia),
        ])
        #expect(rules.hasDragRules(forButton: 6, in: obsidian))
        #expect(!rules.hasDragRules(forButton: 6, in: "com.apple.finder"))
        #expect(!rules.hasDragRules(forButton: 3, in: obsidian))
    }

    @Test func aDragRuleComesBackUnchangedFromJSON() throws {
        let rule = Rule(trigger: .mouseDrag(number: 6, direction: .left), action: .swipe(.back))
        #expect(try JSONDecoder().decode(Rule.self, from: JSONEncoder().encode(rule)) == rule)
    }
}
