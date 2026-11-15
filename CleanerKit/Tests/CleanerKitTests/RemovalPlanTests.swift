import Foundation
import Testing
@testable import CleanerKit

struct RemovalPlanTests {
    @Test func theAppComesFirstFollowedByItsLeftovers() throws {
        let library = try TemporaryLibrary("Caches/com.acme.example/cache.db", "Preferences/com.acme.example.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let items = RemovalPlan.items(forAppAt: app, inLibrary: library.url, otherAppURLs: [])
        #expect(items.map(\.name) == ["Example.app", "com.acme.example", "com.acme.example.plist"])
        #expect(items.map(\.kind) == [.app, .leftover(.caches), .leftover(.preferences)])
    }

    @Test func eachItemIsMeasuredInBytes() throws {
        let library = try TemporaryLibrary()
        try library.write(byteCount: 300, to: "Caches/com.acme.example/one.db")
        try library.write(byteCount: 200, to: "Caches/com.acme.example/inner/two.db")
        try library.write(byteCount: 40, to: "Preferences/com.acme.example.plist")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let sizes = RemovalPlan.items(forAppAt: app, inLibrary: library.url, otherAppURLs: []).map(\.sizeBytes)
        #expect(sizes.dropFirst() == [500, 40])
        #expect(sizes[0] > 0)
    }

    @Test func anAppWithoutABundleIDListsOnlyItself() throws {
        let library = try TemporaryLibrary("Caches/Example/cache.db")
        let app = try library.addApp(named: "Example", bundleID: nil)
        #expect(RemovalPlan.items(forAppAt: app, inLibrary: library.url, otherAppURLs: []).map(\.kind) == [.app])
    }

    @Test func aVendorFolderAnotherInstalledAppMayShareIsLeftOut() throws {
        let library = try TemporaryLibrary("Application Support/Acme/data.db")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let otherApp = try library.addApp(named: "Other", bundleID: "com.acme.other")
        #expect(RemovalPlan.items(forAppAt: app, inLibrary: library.url, otherAppURLs: [otherApp]).map(\.kind) == [.app])
    }

    @Test func aMissingFileMeasuresZero() {
        #expect(DiskSize.bytes(at: URL(filePath: "/nonexistent/\(UUID().uuidString)")) == 0)
    }
}
