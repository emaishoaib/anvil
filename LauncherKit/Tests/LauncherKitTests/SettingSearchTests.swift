import Testing
@testable import LauncherKit

struct SettingSearchTests {
    let useSwitcher = SettingEntry(id: "switcher.isOn", title: "Use Switcher", toolName: "Switcher")
    let useWindows = SettingEntry(id: "windows.isOn", title: "Use Windows", toolName: "Windows")
    let gap = SettingEntry(id: "windows.gap", title: "Gap Between Windows", toolName: "Windows", keywords: ["margin", "spacing"])
    let scrollSpeed = SettingEntry(id: "mouse.scrollSpeed", title: "Scroll Speed", toolName: "Mouse")
    let dpi = SettingEntry(id: "mouse.dpi", title: "Set the DPI", toolName: "Mouse", keywords: ["sensitivity"])

    var entries: [SettingEntry] {
        [useSwitcher, useWindows, gap, scrollSpeed, dpi]
    }

    func titles(for query: String) -> [[String]] {
        SettingSearch.matches(for: query, in: entries).map { $0.entries.map(\.title) }
    }

    @Test func emptyQueryListsEveryEntryInTheOrderGiven() {
        #expect(titles(for: "") == [["Use Switcher"], ["Use Windows", "Gap Between Windows"], ["Scroll Speed", "Set the DPI"]])
    }

    @Test func emptyQueryGroupsEntriesUnderTheirTool() {
        #expect(SettingSearch.matches(for: "", in: entries).map(\.toolName) == ["Switcher", "Windows", "Mouse"])
    }

    @Test func aQueryOfOnlySpacesListsEveryEntry() {
        #expect(titles(for: "  ") == titles(for: ""))
    }

    @Test func entriesThatDoNotMatchAreLeftOut() {
        #expect(titles(for: "scroll") == [["Scroll Speed"]])
    }

    @Test func theToolNameMatchesEveryEntryOfThatTool() {
        #expect(titles(for: "mouse") == [["Scroll Speed", "Set the DPI"]])
    }

    @Test func aKeywordMatchesItsEntry() {
        #expect(titles(for: "spacing") == [["Gap Between Windows"]])
    }

    @Test func equalMatchesKeepTheOrderGiven() {
        #expect(titles(for: "use").prefix(2) == [["Use Switcher"], ["Use Windows"]])
    }

    @Test func betterMatchesComeFirstWithinATool() {
        let speedGain = SettingEntry(id: "mouse.speedGain", title: "Speed Gain", toolName: "Mouse")
        let groups = SettingSearch.matches(for: "speed", in: [scrollSpeed, speedGain])
        #expect(groups.map { $0.entries.map(\.title) } == [["Speed Gain", "Scroll Speed"]])
    }

    @Test func theToolWithTheBestMatchComesFirst() {
        let animationSpeed = SettingEntry(id: "windows.animationSpeed", title: "Animation Speed", toolName: "Windows")
        let speed = SettingEntry(id: "mouse.speed", title: "Speed", toolName: "Mouse")
        let groups = SettingSearch.matches(for: "speed", in: [animationSpeed, speed])
        #expect(groups.map(\.toolName) == ["Mouse", "Windows"])
    }
}
