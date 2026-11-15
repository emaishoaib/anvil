import Foundation
import Testing
@testable import LauncherKit

struct LauncherSearchTests {
    let locale = Locale(identifier: "en_US")
    let safari = InstalledApp(url: URL(filePath: "/Applications/Safari.app"))
    let tenByFourNotes = InstalledApp(url: URL(filePath: "/Applications/10x4 Notes.app"))
    let safariTips = QuickLink(name: "Safari Tips", link: "https://support.apple.com/safari")

    func results(for query: String) -> [SearchResult] {
        LauncherSearch.results(for: query, in: [safari, tenByFourNotes], quickLinks: [safariTips], launchCounts: LaunchCounts(), locale: locale)
    }

    @Test func quickLinksAreListedWithApps() {
        #expect(results(for: "saf") == [.app(safari), .quickLink(safariTips)])
    }

    @Test func aQuickLinkCanBeTheOnlyResult() {
        #expect(results(for: "tips") == [.quickLink(safariTips)])
    }

    @Test func commandsAreListedWithApps() {
        #expect(results(for: "def") == [.command(.defineWord)])
    }

    @Test func aCommandLeftOutOfTheGivenCommandsIsNotListed() {
        let results = LauncherSearch.results(for: "uninstall", in: [safari], commands: [.defineWord, .settings], launchCounts: LaunchCounts(), locale: locale)
        #expect(results.isEmpty)
    }

    @Test func everyRemovableAppIsListedForAnEmptyQuery() {
        let notes = InstalledApp(url: URL(filePath: "/System/Applications/Notes.app"))
        #expect(LauncherSearch.removableApps(matching: "", in: [tenByFourNotes, notes, safari]) == [.app(tenByFourNotes), .app(safari)])
    }

    @Test func removableAppsAreMatchedByName() {
        #expect(LauncherSearch.removableApps(matching: "saf", in: [tenByFourNotes, safari]) == [.app(safari)])
    }

    @Test func appsThatComeWithMacOSAreNeverRemovable() {
        let finder = InstalledApp(url: URL(filePath: "/System/Library/CoreServices/Finder.app"))
        #expect(LauncherSearch.removableApps(matching: "finder", in: [finder]).isEmpty)
    }

    @Test func aSumListsItsAnswerBeforeAnyApps() {
        let answer = Answer(input: "10x4", inputLabel: "Product", output: "40", outputLabel: "Forty", copyText: "40")
        #expect(results(for: "10x4") == [.answer(answer), .app(tenByFourNotes)])
    }

    @Test func anEmptyQueryListsTheMostOpenedResults() {
        let counts = LaunchCounts([safariTips.launchKey: 4, safari.url.path: 1])
        let results = LauncherSearch.results(for: " ", in: [safari, tenByFourNotes], quickLinks: [safariTips], launchCounts: counts, locale: locale)
        #expect(results == [.quickLink(safariTips), .app(safari)])
    }
}
