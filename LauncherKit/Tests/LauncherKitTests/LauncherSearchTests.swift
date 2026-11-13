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

    @Test func aSumListsItsAnswerBeforeAnyApps() {
        let answer = Answer(input: "10x4", inputLabel: "Product", output: "40", outputLabel: "Forty", copyText: "40")
        #expect(results(for: "10x4") == [.answer(answer), .app(tenByFourNotes)])
    }
}
