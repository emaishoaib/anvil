import Foundation
import Testing
@testable import RulesKit

struct RuleActionTests {
    @Test func aMenuPathIsSplitAtEachAngleBracket() {
        #expect(RuleAction.menuPath(from: "View > Terminal") == ["View", "Terminal"])
    }

    @Test func aMenuPathIgnoresSpacesAndEmptySteps() {
        #expect(RuleAction.menuPath(from: "  File >> Open Recent >  ") == ["File", "Open Recent"])
    }

    @Test func aMenuItemRuleComesBackUnchangedFromJSON() throws {
        let rule = Rule(trigger: .shortcut(Keystroke(keyCode: 50, modifiers: 8)), action: .chooseMenuItem(path: ["View", "Terminal"]))
        #expect(try JSONDecoder().decode(Rule.self, from: JSONEncoder().encode(rule)) == rule)
    }

    @Test func aSoundRuleComesBackUnchangedFromJSON() throws {
        let rule = Rule(trigger: .shortcut(Keystroke(keyCode: 35, modifiers: 10)), action: .playSound(name: "Glass"))
        #expect(try JSONDecoder().decode(Rule.self, from: JSONEncoder().encode(rule)) == rule)
    }
}
