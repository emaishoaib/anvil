import Testing
@testable import RulesKit

struct RuleTriggerTests {
    @Test func clicksAndDragsUseAMouseButton() {
        #expect(RuleTrigger.mouseButton(number: 6).usesMouseButton)
        #expect(RuleTrigger.mouseDrag(number: 6, direction: .up).usesMouseButton)
    }

    @Test func shortcutsAndAppEventsDoNotUseAMouseButton() {
        #expect(!RuleTrigger.shortcut(Keystroke(keyCode: 4, modifiers: 8)).usesMouseButton)
        #expect(!RuleTrigger.appOpens.usesMouseButton)
        #expect(!RuleTrigger.appComesToFront.usesMouseButton)
    }
}
