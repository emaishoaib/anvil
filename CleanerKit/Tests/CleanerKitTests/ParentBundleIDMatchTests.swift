import Testing
@testable import CleanerKit

struct ParentBundleIDMatchTests {
    @Test func theShorterIDAndItsPlistAreFound() throws {
        let library = try TemporaryLibrary(
            "Preferences/com.stairways.keyboardmaestro.plist",
            "Application Support/com.stairways.keyboardmaestro/macros.db",
            "Preferences/com.stairways.keyboardmaestro.other.plist"
        )
        #expect(library.leftoverPaths(of: "com.stairways.keyboardmaestro.editor") == [
            "Application Support/com.stairways.keyboardmaestro",
            "Preferences/com.stairways.keyboardmaestro.plist",
        ])
    }

    @Test func aBundleIDWithThreePartsIsNotShortened() throws {
        let library = try TemporaryLibrary("Preferences/com.acme.plist")
        #expect(library.leftoverPaths(of: "com.acme.example").isEmpty)
    }

    @Test func theShorterIDIsLeftAloneWhenAnotherInstalledAppStartsWithIt() throws {
        let library = try TemporaryLibrary("Preferences/com.stairways.keyboardmaestro.plist")
        let paths = library.leftoverPaths(of: "com.stairways.keyboardmaestro.editor", otherInstalledBundleIDs: ["com.stairways.keyboardmaestro.viewer"])
        #expect(paths.isEmpty)
    }

    @Test func applesOwnAppsAreNotShortened() throws {
        let library = try TemporaryLibrary("Preferences/com.apple.dt.plist")
        #expect(library.leftoverPaths(of: "com.apple.dt.Xcode", named: "Xcode").isEmpty)
    }
}
