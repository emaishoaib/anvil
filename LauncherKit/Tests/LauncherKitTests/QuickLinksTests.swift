import Testing
@testable import LauncherKit

struct QuickLinksTests {
    let google = QuickLink(name: "Search Google", link: "https://google.com/search?q={Query}")
    let drive = QuickLink(name: "drive", link: "https://drive.google.com")

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
}
