import Foundation
import Testing
@testable import RulesKit

struct RulesTests {
    let commandH = RuleTrigger.shortcut(Keystroke(keyCode: 4, modifiers: 8))
    let findAndReplace = RuleAction.sendShortcut(Keystroke(keyCode: 3, modifiers: 10))
    let history = RuleAction.sendShortcut(Keystroke(keyCode: 16, modifiers: 8))
    let obsidian = "md.obsidian"

    @Test func aRuleForAllAppsMatchesInAnyApp() {
        let rules = Rules([Rule(trigger: commandH, action: findAndReplace)])
        #expect(rules.rule(for: commandH, in: obsidian)?.action == findAndReplace)
        #expect(rules.rule(for: commandH, in: nil)?.action == findAndReplace)
    }

    @Test func aRuleForChosenAppsOnlyMatchesInThoseApps() {
        let rules = Rules([Rule(trigger: commandH, apps: .only(bundleIDs: [obsidian]), action: findAndReplace)])
        #expect(rules.rule(for: commandH, in: obsidian) != nil)
        #expect(rules.rule(for: commandH, in: "com.apple.finder") == nil)
        #expect(rules.rule(for: commandH, in: nil) == nil)
    }

    @Test func aRuleForChosenAppsWinsOverAnAllAppsRuleWithTheSameTrigger() {
        let everywhere = Rule(trigger: commandH, action: history)
        let inObsidian = Rule(trigger: commandH, apps: .only(bundleIDs: [obsidian]), action: findAndReplace)
        let rules = Rules([everywhere, inObsidian])
        #expect(rules.rule(for: commandH, in: obsidian) == inObsidian)
        #expect(rules.rule(for: commandH, in: "com.apple.finder") == everywhere)
    }

    @Test func aDifferentTriggerMatchesNothing() {
        let rules = Rules([Rule(trigger: commandH, action: findAndReplace)])
        #expect(rules.rule(for: .shortcut(Keystroke(keyCode: 4, modifiers: 9)), in: obsidian) == nil)
    }

    @Test func savingANewRuleAddsItAtTheEnd() {
        let first = Rule(trigger: commandH, action: findAndReplace)
        let second = Rule(trigger: commandH, apps: .only(bundleIDs: [obsidian]), action: history)
        var rules = Rules([first])
        rules.save(second)
        #expect(rules.rules == [first, second])
    }

    @Test func savingAnEditedRuleReplacesItWhereItWas() {
        let first = Rule(trigger: commandH, action: findAndReplace)
        let second = Rule(trigger: commandH, apps: .only(bundleIDs: [obsidian]), action: history)
        var rules = Rules([first, second])
        var edited = first
        edited.action = history
        rules.save(edited)
        #expect(rules.rules == [edited, second])
    }

    @Test func deletingARuleRemovesOnlyThatRule() {
        let first = Rule(trigger: commandH, action: findAndReplace)
        let second = Rule(trigger: commandH, apps: .only(bundleIDs: [obsidian]), action: history)
        var rules = Rules([first, second])
        rules.delete(first)
        #expect(rules.rules == [second])
    }

    @Test func rulesComeBackUnchangedFromJSON() throws {
        let saved = [
            Rule(trigger: commandH, action: findAndReplace),
            Rule(trigger: commandH, apps: .only(bundleIDs: [obsidian]), action: history),
        ]
        let loaded = try JSONDecoder().decode([Rule].self, from: JSONEncoder().encode(saved))
        #expect(loaded == saved)
    }
}
