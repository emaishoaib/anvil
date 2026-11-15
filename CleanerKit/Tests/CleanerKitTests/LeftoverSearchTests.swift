import Testing
@testable import CleanerKit

struct LeftoverSearchTests {
    @Test func filesNamedAfterTheBundleIDAreFoundInEachLibraryFolder() throws {
        let library = try TemporaryLibrary(
            "Application Support/com.example.app/data.db",
            "Caches/com.example.app/cache.db",
            "Preferences/com.example.app.plist",
            "Preferences/ByHost/com.example.app.1A2B3C.plist",
            "Containers/com.example.app/Data",
            "Saved Application State/com.example.app.savedState/window.data",
            "LaunchAgents/com.example.app.helper.plist"
        )
        #expect(library.leftoverPaths(of: "com.example.app") == [
            "Application Support/com.example.app",
            "Caches/com.example.app",
            "Preferences/com.example.app.plist",
            "Preferences/ByHost/com.example.app.1A2B3C.plist",
            "Containers/com.example.app",
            "Saved Application State/com.example.app.savedState",
            "LaunchAgents/com.example.app.helper.plist",
        ])
    }

    @Test func aNameThatOnlyStartsWithTheSameLettersIsLeftAlone() throws {
        let library = try TemporaryLibrary("Caches/com.example.application/cache.db", "Preferences/com.example.apple.plist")
        #expect(library.leftoverPaths(of: "com.example.app").isEmpty)
    }

    @Test func anotherAppsFilesAreLeftAlone() throws {
        let library = try TemporaryLibrary("Preferences/com.other.app.plist", "Caches/com.example.app/cache.db")
        #expect(library.leftoverPaths(of: "com.example.app") == ["Caches/com.example.app"])
    }

    @Test func groupContainersAreFoundAfterATeamOrGroupPrefix() throws {
        let library = try TemporaryLibrary(
            "Group Containers/group.com.example.app/data.db",
            "Group Containers/ABCDE12345.com.example.app/data.db",
            "Caches/group.com.example.app/cache.db"
        )
        #expect(library.leftoverPaths(of: "com.example.app") == [
            "Group Containers/ABCDE12345.com.example.app",
            "Group Containers/group.com.example.app",
        ])
    }

    @Test func scriptsAndContainersAreFoundAfterATeamPrefixButPreferencesAreNot() throws {
        let library = try TemporaryLibrary(
            "Application Scripts/ABCDE12345.com.example.app/script.sh",
            "Containers/ABCDE12345.com.example.app/Data",
            "Preferences/ABCDE12345.com.example.app.plist"
        )
        #expect(library.leftoverPaths(of: "com.example.app") == [
            "Containers/ABCDE12345.com.example.app",
            "Application Scripts/ABCDE12345.com.example.app",
        ])
    }

    @Test func filesNamedAfterAnAppGroupAreFoundInAnyFolder() throws {
        let library = try TemporaryLibrary(
            "Group Containers/group.com.acme.shared/data.db",
            "Application Scripts/ABCDE12345.com.acme/script.sh",
            "Preferences/group.com.acme.shared.plist",
            "Group Containers/group.com.acme.sharedother/data.db"
        )
        #expect(library.leftoverPaths(of: "com.acme.example", appGroups: ["group.com.acme.shared", "abcde12345.com.acme"]) == [
            "Preferences/group.com.acme.shared.plist",
            "Group Containers/group.com.acme.shared",
            "Application Scripts/ABCDE12345.com.acme",
        ])
    }

    @Test func filesNamedAfterTheBundleIDAreFoundInThePerUserCacheAndTempFolders() throws {
        let library = try TemporaryLibrary(
            "User Cache/com.example.app/cache.db",
            "User Cache/com.example.app.helper/cache.db",
            "User Temp/com.example.app.url_fetcher.34cxsS/data",
            "User Temp/com.example.application/data"
        )
        #expect(library.leftoverPaths(of: "com.example.app") == [
            "User Cache/com.example.app",
            "User Cache/com.example.app.helper",
            "User Temp/com.example.app.url_fetcher.34cxsS",
        ])
    }

    @Test func foldersNamedAfterTheAppAreNotLookedForInThePerUserFolders() throws {
        let library = try TemporaryLibrary("User Cache/Example/cache.db", "User Temp/Example/data")
        #expect(library.leftoverPaths(of: "com.acme.example").isEmpty)
    }

    @Test func aPerUserFolderThatCannotBeFoundIsSkipped() throws {
        let library = try TemporaryLibrary("Caches/com.example.app/cache.db")
        let roots = SearchRoots(home: library.url.appending(path: "Home"), library: library.url, userCache: nil, userTemp: nil)
        let leftovers = LeftoverSearch.leftovers(of: AppIdentity(bundleID: "com.example.app", name: "Example"), in: roots, otherInstalledBundleIDs: [])
        #expect(leftovers.map(\.folder) == [.caches])
    }

    @Test func theCurrentUsersPerUserFoldersAreFound() {
        let roots = SearchRoots.current
        #expect(roots.userCache?.path(percentEncoded: false).hasSuffix("/C/") == true)
        #expect(roots.userTemp?.path(percentEncoded: false).hasSuffix("/T/") == true)
    }

    @Test func letterCaseIsIgnored() throws {
        let library = try TemporaryLibrary("Preferences/COM.Example.App.plist")
        #expect(library.leftoverPaths(of: "com.example.app") == ["Preferences/COM.Example.App.plist"])
    }

    @Test func missingLibraryFoldersAreSkipped() throws {
        let library = try TemporaryLibrary()
        #expect(library.leftoverPaths(of: "com.example.app").isEmpty)
    }

    @Test func anEmptyBundleIDFindsNothing() throws {
        let library = try TemporaryLibrary("Caches/.hidden", "Preferences/com.example.app.plist")
        #expect(library.leftoverPaths(of: "").isEmpty)
    }
}
