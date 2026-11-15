import Testing
@testable import CleanerKit

struct WalkSearchTests {
    private let example = AppIdentity(bundleID: "com.acme.example", name: "Example")

    @Test func namesAreFoundAtAnyDepth() throws {
        let library = try TemporaryLibrary("Users/me/Library/Caches/com.acme.example/cache.db", "private/var/folders/xy/C/com.apple.WebKit.GPU+com.acme.example/state")
        #expect(foundPaths(of: example, among: [example], in: library) == [
            "Users/me/Library/Caches/com.acme.example",
            "private/var/folders/xy/C/com.apple.WebKit.GPU+com.acme.example",
        ])
    }

    @Test func aFolderNamedAfterTheAppIsFoundWithoutWhatIsInsideIt() throws {
        let library = try TemporaryLibrary("Application Support/Example/Example.log")
        #expect(foundPaths(of: example, among: [example], in: library) == ["Application Support/Example"])
    }

    @Test func aNameInsideAnotherAppsFolderIsLeftToThatApp() throws {
        let library = try TemporaryLibrary("Application Support/com.other.cleaner/Records/com.acme.example.plist")
        let cleaner = AppIdentity(bundleID: "com.other.cleaner", name: "Cleaner")
        #expect(foundPaths(of: example, among: [example, cleaner], in: library).isEmpty)
        #expect(foundPaths(of: cleaner, among: [example, cleaner], in: library) == ["Application Support/com.other.cleaner"])
    }

    @Test func aNameBelongingToTwoAppsGoesToTheOneWhoseWordsRunLongest() throws {
        let library = try TemporaryLibrary("Caches/com.acme.example.canary/cache.db")
        let canary = AppIdentity(bundleID: "com.acme.example.canary", name: "Example Canary")
        #expect(foundPaths(of: example, among: [example, canary], in: library).isEmpty)
        #expect(foundPaths(of: canary, among: [example, canary], in: library) == ["Caches/com.acme.example.canary"])
    }

    @Test func aNameBelongingToTwoAppsEquallyGoesToBoth() throws {
        let library = try TemporaryLibrary("Caches/Example/cache.db")
        let twin = AppIdentity(bundleID: "com.other.example", name: "Example")
        #expect(foundPaths(of: example, among: [example, twin], in: library) == ["Caches/Example"])
        #expect(foundPaths(of: twin, among: [example, twin], in: library) == ["Caches/Example"])
    }

    @Test func namesThatBelongToNoAppAreNotFound() throws {
        let library = try TemporaryLibrary("Caches/com.other.app/cache.db", "Logs/ARExampleQuery.h")
        #expect(foundPaths(of: example, among: [example], in: library).isEmpty)
    }

    private func foundPaths(of app: AppIdentity, among apps: [AppIdentity], in library: TemporaryLibrary) -> [String] {
        (WalkSearch.matches(of: apps, in: [library.url])[app] ?? []).map(library.relativePath(of:)).sorted()
    }
}
