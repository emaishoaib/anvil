import Foundation
import Testing
@testable import LauncherKit

struct QuickLinkFileTests {
    let code = URL(filePath: "/Applications/Visual Studio Code.app")

    func app(named name: String) -> URL? {
        name == "Visual Studio Code" ? code : nil
    }

    @Test func aFileBecomesQuickLinks() throws {
        let json = """
        [
          { "name": "code quire", "link": "~/docs/repos/quire", "icon": "default", "openWith": "Visual Studio Code" },
          { "name": "Search Google", "link": "https://google.com/search?q={Query}", "icon": "link" }
        ]
        """
        let links = try QuickLinkFile.decode(Data(json.utf8), appNamed: app(named:))
        #expect(links.map(\.name) == ["code quire", "Search Google"])
        #expect(links.map(\.link) == ["~/docs/repos/quire", "https://google.com/search?q={Query}"])
        #expect(links.map(\.openWith) == [code, nil])
    }

    @Test func anAppThatIsNotInstalledFallsBackToTheDefault() throws {
        let json = #"[{ "name": "Notes", "link": "~/notes", "openWith": "Missing App" }]"#
        #expect(try QuickLinkFile.decode(Data(json.utf8), appNamed: app(named:)).first?.openWith == nil)
    }

    @Test func exportedLinksReadBackTheSame() throws {
        let links = [
            QuickLink(name: "code quire", link: "~/docs/repos/quire", openWith: code),
            QuickLink(name: "Search Google", link: "https://google.com/search?q={Query}"),
        ]
        let read = try QuickLinkFile.decode(QuickLinkFile.encode(links), appNamed: app(named:))
        #expect(read.map(\.name) == links.map(\.name))
        #expect(read.map(\.link) == links.map(\.link))
        #expect(read.map(\.openWith) == links.map(\.openWith))
    }

    @Test func theAppIsSavedByName() throws {
        let data = try QuickLinkFile.encode([QuickLink(name: "code quire", link: "~/docs/repos/quire", openWith: code)])
        #expect(String(decoding: data, as: UTF8.self).contains(#""openWith" : "Visual Studio Code""#))
    }

    @Test func aLinkWithoutAnAppIsSavedWithoutOne() throws {
        let data = try QuickLinkFile.encode([QuickLink(name: "Search Google", link: "https://google.com")])
        #expect(!String(decoding: data, as: UTF8.self).contains("openWith"))
    }

    @Test func aFileThatIsNotAListOfLinksIsRejected() {
        #expect(throws: (any Error).self) {
            try QuickLinkFile.decode(Data(#"{ "quickLinks": [] }"#.utf8), appNamed: app(named:))
        }
    }
}
