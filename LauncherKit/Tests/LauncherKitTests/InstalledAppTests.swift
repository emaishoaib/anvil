import Foundation
import Testing
@testable import LauncherKit

struct InstalledAppTests {
    func app(_ name: String) -> InstalledApp {
        InstalledApp(url: URL(filePath: "/Applications/\(name).app"))
    }

    @Test func nameLeavesOutTheAppExtension() {
        #expect(app("Safari").name == "Safari")
    }

    @Test func queryAtTheStartOfTheNameIsANamePrefixMatch() {
        #expect(app("Safari").match(for: "saf") == .namePrefix)
    }

    @Test func matchingIgnoresCase() {
        #expect(app("Safari").match(for: "SAF") == .namePrefix)
    }

    @Test func queryAtTheStartOfALaterWordIsAWordPrefixMatch() {
        #expect(app("Visual Studio Code").match(for: "code") == .wordPrefix)
    }

    @Test func queryInsideAWordIsAContainsMatch() {
        #expect(app("Xcode").match(for: "code") == .contains)
    }

    @Test func queryMissingFromTheNameDoesNotMatch() {
        #expect(app("Safari").match(for: "mail") == nil)
    }
}
