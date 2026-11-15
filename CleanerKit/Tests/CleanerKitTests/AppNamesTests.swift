import Foundation
import Testing
@testable import CleanerKit

struct AppNamesTests {
    func leftoverPaths(in library: TemporaryLibrary, forAppAt app: URL, otherAppURLs: [URL] = []) -> [String] {
        RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: otherAppURLs).dropFirst().map { library.relativePath(of: $0.url) }
    }

    @Test func theBundleNameExecutableAndFileNameWithoutVersionAreOtherNames() throws {
        let library = try TemporaryLibrary()
        let app = try library.addApp(named: "Tinderbox 11", bundleID: "com.acme.tinderbox", bundleName: "Tinderbox Pro", executableName: "TinderboxApp")
        #expect(AppIdentity(appAt: app)?.otherNames == ["Tinderbox Pro", "TinderboxApp", "Tinderbox"])
    }

    @Test func namesShorterThanThreeLettersOrRepeatingTheAppsNameAreLeftOut() throws {
        let library = try TemporaryLibrary()
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example", bundleName: "example", executableName: "Ex")
        #expect(AppIdentity(appAt: app)?.otherNames == [])
    }

    @Test func aFolderNamedAfterTheBundleNameIsFound() throws {
        let library = try TemporaryLibrary("Application Support/Code/settings.json", "Caches/Code/cache.db")
        let app = try library.addApp(named: "Visual Studio Code", bundleID: "com.acme.code", bundleName: "Code")
        #expect(leftoverPaths(in: library, forAppAt: app) == ["Application Support/Code", "Caches/Code"])
    }

    @Test func inTheHomeFolderOnlyTheFileNameCounts() throws {
        let library = try TemporaryLibrary("Home/Code/project/main.swift")
        let app = try library.addApp(named: "Visual Studio Code", bundleID: "com.acme.code", bundleName: "Code")
        #expect(leftoverPaths(in: library, forAppAt: app).isEmpty)
    }

    @Test func theNameOfANestedAppStartingWithTheAppsNameIsFound() throws {
        let library = try TemporaryLibrary("Application Support/Docker Desktop/settings.json", "Application Support/Updater/state")
        let app = try library.addApp(named: "Docker", bundleID: "com.acme.docker", helpers: [
            "MacOS/Docker Desktop.app": "com.electron.dockerdesktop",
            "Helpers/Updater.app": "com.other.updater",
        ])
        #expect(leftoverPaths(in: library, forAppAt: app) == ["Application Support/Docker Desktop"])
    }

    @Test func aNameAnotherInstalledAppGoesByIsLeftToThatApp() throws {
        let library = try TemporaryLibrary("Application Support/Code/settings.json")
        let app = try library.addApp(named: "Visual Studio Code", bundleID: "com.acme.code", bundleName: "Code")
        let otherApp = try library.addApp(named: "Code", bundleID: "com.other.code")
        #expect(leftoverPaths(in: library, forAppAt: app, otherAppURLs: [otherApp]).isEmpty)
    }
}
