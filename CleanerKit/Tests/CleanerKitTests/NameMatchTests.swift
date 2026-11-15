import Testing
@testable import CleanerKit

struct NameMatchTests {
    @Test func foldersNamedAfterTheAppAreFoundInSupportCachesAndLogs() throws {
        let library = try TemporaryLibrary("Application Support/Example/data.db", "Caches/Example/cache.db", "Logs/Example/today.log")
        #expect(library.leftoverPaths(of: "com.acme.example") == [
            "Application Support/Example",
            "Caches/Example",
            "Logs/Example",
        ])
    }

    @Test func foldersNamedAfterTheAppAreNotLookedForElsewhere() throws {
        let library = try TemporaryLibrary("Preferences/Example", "Containers/Example/Data", "LaunchAgents/Example")
        #expect(library.leftoverPaths(of: "com.acme.example").isEmpty)
    }

    @Test func spacesAndLetterCaseInTheAppNameAreIgnored() throws {
        let library = try TemporaryLibrary("Application Support/visualnotes/data.db")
        #expect(library.leftoverPaths(of: "com.acme.notes", named: "Visual Notes") == ["Application Support/visualnotes"])
    }

    @Test func theVendorsFolderIsFoundWhenNoOtherAppComesFromTheVendor() throws {
        let library = try TemporaryLibrary("Application Support/Acme/data.db")
        #expect(library.leftoverPaths(of: "com.acme.example", otherInstalledBundleIDs: ["com.other.app"]) == ["Application Support/Acme"])
    }

    @Test func theVendorsFolderIsLeftAloneWhenAnotherAppComesFromTheVendor() throws {
        let library = try TemporaryLibrary("Application Support/Acme/data.db")
        #expect(library.leftoverPaths(of: "com.acme.example", otherInstalledBundleIDs: ["com.acme.other"]).isEmpty)
    }

    @Test func theAppItselfAmongTheInstalledAppsDoesNotShareItsVendor() throws {
        let library = try TemporaryLibrary("Application Support/Acme/data.db")
        #expect(library.leftoverPaths(of: "com.acme.example", otherInstalledBundleIDs: ["com.acme.example"]) == ["Application Support/Acme"])
    }

    @Test func aBundleIDWithTwoPartsHasNoVendorFolder() throws {
        let library = try TemporaryLibrary("Application Support/acme/data.db")
        #expect(library.leftoverPaths(of: "acme.example", named: "Something").isEmpty)
    }

    @Test func applesOwnAppsAreOnlyFoundByTheirBundleID() throws {
        let library = try TemporaryLibrary("Application Support/Notes/data.db", "Application Support/Apple/data.db", "Containers/com.apple.Notes/Data")
        #expect(library.leftoverPaths(of: "com.apple.Notes", named: "Notes") == ["Containers/com.apple.Notes"])
    }

    @Test func applesFilesAreNeverFoundByName() throws {
        let library = try TemporaryLibrary("Application Support/com.apple.sharedfilelist/data")
        #expect(library.leftoverPaths(of: "com.acme.example", named: "com.apple.sharedfilelist").isEmpty)
    }

    @Test func aFolderInTheHomeFolderNamedAfterTheAppIsFound() throws {
        let library = try TemporaryLibrary("Home/Visual Notes/files/readme", "Home/Projects/notes.txt")
        #expect(library.leftoverPaths(of: "com.acme.notes", named: "VisualNotes") == ["Home/Visual Notes"])
    }

    @Test func aHiddenFolderInTheHomeFolderNamedAfterTheAppIsFoundButNotElsewhere() throws {
        let library = try TemporaryLibrary("Home/.example/config.json", "Home/..example/config.json", "Application Support/.example/data")
        #expect(library.leftoverPaths(of: "com.acme.example") == ["Home/.example"])
    }

    @Test func aHiddenFolderInTheHomeFolderNamedAfterTheBundleIDsLastPartIsFound() throws {
        let library = try TemporaryLibrary("Home/.vscode/extensions.json", "Home/vscode/notes.txt")
        #expect(library.leftoverPaths(of: "com.microsoft.VSCode", named: "Visual Studio Code") == ["Home/.vscode"])
    }

    @Test func aGenericBundleIDEndingNeverNamesAHiddenFolder() throws {
        let library = try TemporaryLibrary("Home/.mac/settings", "Home/.app/settings")
        #expect(library.leftoverPaths(of: "com.postmanlabs.mac", named: "Postman").isEmpty)
        #expect(library.leftoverPaths(of: "com.acme.app", named: "Acme Tool").isEmpty)
    }

    @Test func aFolderInTheHomeFolderNamedAfterTheVendorIsLeftAlone() throws {
        let library = try TemporaryLibrary("Home/Acme/data.db")
        #expect(library.leftoverPaths(of: "com.acme.example").isEmpty)
    }

    @Test func theFoldersMacOSMakesInTheHomeFolderNeverMatch() throws {
        let library = try TemporaryLibrary("Home/Documents/report.pdf", "Home/Downloads/file.zip")
        #expect(library.leftoverPaths(of: "com.acme.documents", named: "Documents").isEmpty)
        #expect(library.leftoverPaths(of: "com.acme.downloads", named: "Downloads").isEmpty)
    }

    @Test func aFileNamedAfterTheAppWithAnExtensionIsFound() throws {
        let library = try TemporaryLibrary(
            "Logs/Example.log",
            "Preferences/Example.plist",
            "Caches/example.db",
            "Application Support/Example.json"
        )
        #expect(library.leftoverPaths(of: "com.acme.example") == [
            "Application Support/Example.json",
            "Caches/example.db",
            "Preferences/Example.plist",
            "Logs/Example.log",
        ])
    }

    @Test func aFileNamedAfterAnotherOfTheAppsNamesWithAnExtensionIsFound() throws {
        let library = try TemporaryLibrary("Preferences/Code.plist")
        #expect(library.leftoverPaths(of: "com.acme.code", named: "Visual Studio Code", otherNames: ["Code"]) == ["Preferences/Code.plist"])
    }

    @Test func aFileWithAnExtensionIsLeftAloneWhenTheRestIsNotTheAppsName() throws {
        let library = try TemporaryLibrary(
            "Preferences/Example Helper.plist",
            "Preferences/Example.backup.plist",
            "Preferences/Example.not-an-extension",
            "Containers/Example.plist",
            "Home/Example.txt"
        )
        #expect(library.leftoverPaths(of: "com.acme.example").isEmpty)
    }
}
