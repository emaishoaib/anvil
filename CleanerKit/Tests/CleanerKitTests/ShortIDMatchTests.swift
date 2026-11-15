import Testing
@testable import CleanerKit

struct ShortIDMatchTests {
    @Test func aBundleIDStyleNameEndingInTheAppsNameIsFound() throws {
        let library = try TemporaryLibrary(
            "Preferences/io.example.plist",
            "Saved Application State/org.example.savedState/window.data",
            "Caches/someone.Example/cache.db"
        )
        #expect(library.leftoverPaths(of: "com.acme.example-app") == [
            "Caches/someone.Example",
            "Preferences/io.example.plist",
            "Saved Application State/org.example.savedState",
        ])
    }

    @Test func anotherOfTheAppsNamesCountsAsTheLastPart() throws {
        let library = try TemporaryLibrary("Preferences/com.ringcentral.RingCentral Phone.plist")
        #expect(library.leftoverPaths(of: "com.ringcentral.softphone", named: "RingCentral", otherNames: ["RingCentral Phone"]) == [
            "Preferences/com.ringcentral.RingCentral Phone.plist",
        ])
    }

    @Test func aNameWhoseLastPartIsNotTheAppsNameIsLeftAlone() throws {
        let library = try TemporaryLibrary(
            "Preferences/io.examples.plist",
            "Preferences/io.example.backup.plist",
            "Preferences/example.plist.bak"
        )
        #expect(library.leftoverPaths(of: "com.acme.example-app").isEmpty)
    }

    @Test func theHomeFolderAndApplesNamesAreLeftAlone() throws {
        let library = try TemporaryLibrary("Home/io.example/notes.txt", "Preferences/com.apple.example.plist")
        #expect(library.leftoverPaths(of: "com.acme.example-app").isEmpty)
    }

    @Test func anotherInstalledAppsBundleIDIsLeftToThatApp() throws {
        let library = try TemporaryLibrary("Preferences/com.other.example.plist", "Caches/com.other.example.helper/cache.db")
        let paths = library.leftoverPaths(of: "com.acme.example-app", otherInstalledBundleIDs: ["com.other.example"])
        #expect(paths.isEmpty)
    }
}
