import Testing
@testable import CleanerKit

struct LeftoverIndexTests {
    @Test func eachAppGetsTheNamesFoundForItButNotItsOwnBundle() throws {
        let library = try TemporaryLibrary("Caches/com.acme.example/cache.db", "Logs/Other.log")
        let example = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let other = try library.addApp(named: "Other", bundleID: "com.acme.other")
        let index = LeftoverIndex(appURLs: [example, other], walking: [library.url])
        #expect(index.finds(forAppAt: example).map(library.relativePath(of:)) == ["Caches/com.acme.example"])
        #expect(index.finds(forAppAt: other).map(library.relativePath(of:)) == ["Logs/Other.log"])
    }

    @Test func anAppWithoutABundleIDHasNoFinds() throws {
        let library = try TemporaryLibrary("Caches/Example/cache.db")
        let app = try library.addApp(named: "Example", bundleID: nil)
        #expect(LeftoverIndex(appURLs: [app], walking: [library.url]).finds(forAppAt: app).isEmpty)
    }
}
