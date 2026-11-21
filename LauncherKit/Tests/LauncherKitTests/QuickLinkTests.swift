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

    @Test func aLinkMatchesWordsSpreadAcrossItsNameAndHost() {
        let link = QuickLink(name: "asig uk tax", link: "https://www.tax.service.gov.uk/personal-account")
        #expect(link.match(for: "asig uk gov") == .hostWordPrefix)
        #expect(link.match(for: "gov") == .hostWordPrefix)
        #expect(link.match(for: "asig tax") == .everyWordPrefix)
    }

    @Test func aLinkDoesNotMatchWordsOutsideItsHost() {
        let link = QuickLink(name: "asig uk tax", link: "https://www.tax.service.gov.uk/personal-account")
        #expect(link.match(for: "personal") == nil)
        #expect(link.match(for: "www") == nil)
        #expect(link.match(for: "https") == nil)
    }

    @Test func aFilePathMatchesOnlyByName() {
        #expect(QuickLink(name: "Workshop", link: "~/docs/repos/workshop").match(for: "repos") == nil)
    }

    @Test func placeholdersAreTheWordsInBracesInOrder() {
        let link = QuickLink(name: "Maps", link: "https://maps.example.com/{From}/{To}?from={From}")
        #expect(link.placeholders == ["From", "To"])
    }

    @Test func aLinkHasAtMostThreePlaceholders() {
        let link = QuickLink(name: "Many", link: "https://example.com/{A}/{B}/{C}/{D}")
        #expect(link.placeholders == ["A", "B", "C"])
    }

    @Test func typedTextIsEncodedIntoTheLink() {
        let link = QuickLink(name: "Search Google", link: "https://google.com/search?q={Query}")
        #expect(link.target(filling: ["cats & dogs"]) == URL(string: "https://google.com/search?q=cats%20%26%20dogs"))
    }

    @Test func everyCopyOfAPlaceholderIsFilled() {
        let link = QuickLink(name: "Maps", link: "https://example.com/{Place}?near={Place}")
        #expect(link.target(filling: ["york"]) == URL(string: "https://example.com/york?near=york"))
    }

    @Test func placeholdersLeftEmptyAreRemoved() {
        let link = QuickLink(name: "Search Google", link: "https://google.com/search?q={Query}")
        #expect(link.target == URL(string: "https://google.com/search?q="))
    }

    @Test func aFilePathIsFilledWithoutEncoding() {
        let link = QuickLink(name: "Repo", link: "/Users/me/repos/{Repo}")
        #expect(link.target(filling: ["my repo"]) == URL(filePath: "/Users/me/repos/my repo"))
    }

    @Test func aDuplicateIsANewLinkNamedAsACopy() {
        let original = QuickLink(name: "Listings", link: "https://facebook.com", openWith: URL(filePath: "/Applications/Safari.app"))
        let copy = original.duplicate
        #expect(copy.id != original.id)
        #expect(copy.name == "Listings copy")
        #expect(copy.link == original.link)
        #expect(copy.openWith == original.openWith)
    }

    @Test func aWebLinkBelongsToItsSite() {
        let link = QuickLink(name: "Search Google", link: "https://www.google.com/search?q={Query}")
        #expect(link.site == URL(string: "https://www.google.com"))
    }

    @Test func filesAndOtherSchemesHaveNoSite() {
        #expect(QuickLink(name: "Workshop", link: "~/docs/repos/workshop").site == nil)
        #expect(QuickLink(name: "Mail", link: "mailto:someone@example.com").site == nil)
    }
}
