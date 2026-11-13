import Foundation
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

    @Test func aWebLinkShowsItsHostWithoutWww() {
        #expect(QuickLink(name: "Listings", link: "https://www.facebook.com/marketplace/you/selling").host == "facebook.com")
        #expect(QuickLink(name: "Docs", link: "https://user@Docs.Google.com:443/document").host == "docs.google.com")
    }

    @Test func aFilePathHasNoHost() {
        #expect(QuickLink(name: "Workshop", link: "~/docs/repos/workshop").host == nil)
        #expect(QuickLink(name: "Mail", link: "mailto:someone@example.com").host == nil)
    }

    @Test func aFilePathOpensTheFileInTheHomeFolder() {
        let link = QuickLink(name: "Workshop", link: "~/docs/repos/workshop")
        #expect(link.target == URL(filePath: NSHomeDirectory()).appending(path: "docs/repos/workshop"))
    }

    @Test func aWebLinkOpensItsAddress() {
        #expect(QuickLink(name: "Google", link: "https://google.com").target == URL(string: "https://google.com"))
    }

    @Test func aLinkMatchesWordsInItsName() {
        let link = QuickLink(name: "asig facebook marketplace my listings", link: "https://facebook.com")
        #expect(link.match(for: "faceb") == .wordPrefix)
        #expect(link.match(for: "asig") == .namePrefix)
        #expect(link.match(for: "twitter") == nil)
    }
}
