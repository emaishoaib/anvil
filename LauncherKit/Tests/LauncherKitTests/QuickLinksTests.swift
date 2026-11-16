import Foundation
import Testing
@testable import LauncherKit

struct QuickLinksTests {
    let google = QuickLink(name: "Search Google", link: "https://google.com/search?q={Query}")
    let drive = QuickLink(name: "drive", link: "https://drive.google.com")
    let safari = URL(filePath: "/Applications/Safari.app")

    @Test func linksAreListedByNameWhateverTheirCase() {
        #expect(QuickLinks([google, drive]).links == [drive, google])
    }

    @Test func savingANewLinkAddsIt() {
        var links = QuickLinks([google])
        links.save(drive)
        #expect(links.links == [drive, google])
    }

    @Test func savingAnEditedLinkReplacesTheOldOne() {
        var links = QuickLinks([google, drive])
        var renamed = google
        renamed.name = "Google"
        links.save(renamed)
        #expect(links.links == [drive, renamed])
    }

    @Test func deletingALinkRemovesOnlyThatLink() {
        var links = QuickLinks([google, drive])
        links.delete(google)
        #expect(links.links == [drive])
    }

    @Test func mergingSkipsLinksThatAreAlreadyTheSame() {
        var links = QuickLinks([google])
        let copyOfGoogle = QuickLink(name: google.name, link: google.link)
        let result = links.merge([copyOfGoogle, drive, drive])
        #expect(result.added == 1)
        #expect(result.updated == 0)
        #expect(result.skipped == 2)
        #expect(links.links == [drive, google])
    }

    @Test func mergingTakesTheAppFromALinkWithTheSameNameAndLink() {
        var links = QuickLinks([google])
        let googleInSafari = QuickLink(name: google.name, link: google.link, openWith: safari)
        let result = links.merge([googleInSafari])
        #expect(result.updated == 1)
        #expect(links.links.map(\.id) == [google.id])
        #expect(links.links.map(\.openWith) == [safari])
    }

    @Test func mergingALinkWithoutAnAppGoesBackToTheDefault() {
        var googleInSafari = google
        googleInSafari.openWith = safari
        var links = QuickLinks([googleInSafari])
        let result = links.merge([QuickLink(name: google.name, link: google.link)])
        #expect(result.updated == 1)
        #expect(links.links.map(\.openWith) == [nil])
    }
}
