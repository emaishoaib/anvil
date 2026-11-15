import Foundation
import Testing
@testable import CleanerKit

struct RemovalPlanTests {
    @Test func theAppComesFirstFollowedByItsLeftovers() throws {
        let library = try TemporaryLibrary("Caches/com.acme.example/cache.db", "Preferences/com.acme.example.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let items = RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [])
        #expect(items.map(\.name) == ["Example.app", "com.acme.example", "com.acme.example.plist"])
        #expect(items.map(\.kind) == [.app, .leftover(.caches), .leftover(.preferences)])
    }

    @Test func eachItemIsMeasuredInBytes() throws {
        let library = try TemporaryLibrary()
        try library.write(byteCount: 300, to: "Caches/com.acme.example/one.db")
        try library.write(byteCount: 200, to: "Caches/com.acme.example/inner/two.db")
        try library.write(byteCount: 40, to: "Preferences/com.acme.example.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let sizes = RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: []).map(\.sizeBytes)
        #expect(sizes.dropFirst() == [500, 40])
        #expect(sizes[0] > 0)
    }

    @Test func anAppWithoutABundleIDListsOnlyItself() throws {
        let library = try TemporaryLibrary("Caches/Example/cache.db")
        let app = try library.addApp(named: "Example", bundleID: nil)
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: []).map(\.kind) == [.app])
    }

    @Test func aVendorFolderAnotherInstalledAppMayShareIsLeftOut() throws {
        let library = try TemporaryLibrary("Application Support/Acme/data.db")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let otherApp = try library.addApp(named: "Other", bundleID: "com.acme.other")
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [otherApp]).map(\.kind) == [.app])
    }

    @Test func filesOfAHelperDeepInsideTheAppAreFound() throws {
        let library = try TemporaryLibrary("Preferences/com.acme.updater.plist", "LaunchAgents/com.acme.updater.wake.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example", helpers: [
            "Frameworks/Example.framework/Versions/A/Helpers/Updater.app": "com.acme.updater",
        ])
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: []).map(\.name) == [
            "Example.app",
            "com.acme.updater.plist",
            "com.acme.updater.wake.plist",
        ])
    }

    @Test func aHelperFromAnotherVendorIsLeftOut() throws {
        let library = try TemporaryLibrary("Caches/org.sparkle-project.Sparkle/cache.db")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example", helpers: ["XPCServices/Installer.xpc": "org.sparkle-project.Sparkle"])
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: []).map(\.kind) == [.app])
    }

    @Test func aHelperAnotherAppFromTheSameVendorAlsoCarriesIsLeftOut() throws {
        let library = try TemporaryLibrary("Preferences/com.acme.errorreporting.plist", "Preferences/com.acme.updater.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example", helpers: [
            "Helpers/Reporter.app": "com.acme.errorreporting",
            "Helpers/Updater.app": "com.acme.updater",
        ])
        let otherApp = try library.addApp(named: "Other", bundleID: "com.acme.other", helpers: ["PlugIns/Reporter.appex": "com.acme.errorreporting"])
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [otherApp]).map(\.name) == ["Example.app", "com.acme.updater.plist"])
    }

    @Test func aHelperThatIsAnotherInstalledAppIsLeftOut() throws {
        let library = try TemporaryLibrary("Preferences/com.acme.autoupdate.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example", helpers: ["Helpers/AutoUpdate.app": "com.acme.autoupdate"])
        let otherApp = try library.addApp(named: "AutoUpdate", bundleID: "com.acme.autoupdate")
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [otherApp]).map(\.kind) == [.app])
    }

    @Test func helpersInsideApplesOwnAppsAreLeftOut() throws {
        let library = try TemporaryLibrary("Preferences/com.apple.dt.helper.plist")
        let app = try library.addApp(named: "Xcode", bundleID: "com.apple.dt.Xcode", helpers: ["Helpers/Helper.app": "com.apple.dt.helper"])
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: []).map(\.kind) == [.app])
    }

    @Test func theAppAndLibraryLeftoversStartTicked() throws {
        let library = try TemporaryLibrary("Caches/com.acme.example/cache.db", "Preferences/com.acme.example.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let items = RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [])
        #expect(items.map(\.startsTicked) == [true, true, true])
    }

    @Test func aLeftoverInTheHomeFolderStartsUnticked() throws {
        let library = try TemporaryLibrary("Caches/com.acme.example/cache.db", "Home/Example/files/readme")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let items = RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [])
        #expect(items.map { library.relativePath(of: $0.url) }.dropFirst() == ["Caches/com.acme.example", "Home/Example"])
        #expect(items.map(\.startsTicked) == [true, true, false])
    }

    @Test func aMissingFileMeasuresZero() {
        #expect(DiskSize.bytes(at: URL(filePath: "/nonexistent/\(UUID().uuidString)")) == 0)
    }
}
