import Testing
@testable import LauncherKit

struct QuickLinkTests {
    @Test func aLinkWithANameAndALinkIsComplete() {
        #expect(QuickLink(name: "Search Google", link: "https://google.com/search?q={Query}").isComplete)
    }

    @Test func aBlankNameOrLinkIsIncomplete() {
        #expect(!QuickLink(name: "  ", link: "https://google.com").isComplete)
        #expect(!QuickLink(name: "Google", link: "").isComplete)
    }

    @Test func aWebLinkHasItsScheme() {
        let link = QuickLink(name: "Google", link: "HTTPS://google.com")
        #expect(link.scheme == "https")
        #expect(!link.isFilePath)
    }

    @Test func aPathInTheHomeFolderIsAFilePath() {
        let link = QuickLink(name: "Workshop", link: "~/docs/repos/workshop")
        #expect(link.isFilePath)
        #expect(link.scheme == nil)
    }

    @Test func textWithoutASchemeHasNone() {
        #expect(QuickLink(name: "Notes", link: "google.com").scheme == nil)
        #expect(QuickLink(name: "Time", link: "10:30").scheme == nil)
    }
}
