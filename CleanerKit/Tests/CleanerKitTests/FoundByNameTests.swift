import Foundation
import Testing
@testable import CleanerKit

struct FoundByNameTests {
    @Test func aNameFoundRightInsideAPlaceAppsKeepFilesInStartsTicked() throws {
        let library = try TemporaryLibrary("User Cache/com.apple.WebKit.GPU+com.acme.example/state", "System Library/Application Support/Example/data.db")
        let items = try plan(in: library, foundByName: ["User Cache/com.apple.WebKit.GPU+com.acme.example", "System Library/Application Support/Example"])
        #expect(items.dropFirst().map(\.kind) == [.foundByName, .foundByName])
        #expect(items.dropFirst().map(\.startsTicked) == [true, true])
    }

    @Test func aNameFoundInsideAnotherFolderStartsUnticked() throws {
        let library = try TemporaryLibrary("Application Support/Logi/Icons/com.acme.example.png")
        let items = try plan(in: library, foundByName: ["Application Support/Logi/Icons/com.acme.example.png"])
        #expect(items.dropFirst().map(\.startsTicked) == [false])
    }

    @Test func aNameFoundAmongTheUsersOwnFilesStartsUnticked() throws {
        let library = try TemporaryLibrary("Home/Projects/Example/notes.txt")
        let items = try plan(in: library, foundByName: ["Home/Projects/Example"])
        #expect(items.dropFirst().map(\.startsTicked) == [false])
    }

    @Test func aNameTheSearchFoldersAlsoFindIsListedOnce() throws {
        let library = try TemporaryLibrary("Caches/com.acme.example/cache.db")
        let items = try plan(in: library, foundByName: ["Caches/com.acme.example"])
        #expect(items.dropFirst().map(\.kind) == [.leftover(.caches)])
    }

    @Test func aNameFoundInsideALeftoverIsLeftOut() throws {
        let library = try TemporaryLibrary("Application Support/Example/Example Helper/state")
        let items = try plan(in: library, foundByName: ["Application Support/Example/Example Helper"])
        #expect(items.dropFirst().map { library.relativePath(of: $0.url) } == ["Application Support/Example"])
    }

    @Test func aNameThatHasGoneSinceTheWalkIsLeftOut() throws {
        let library = try TemporaryLibrary("User Cache/Example/state")
        let items = try plan(in: library, foundByName: ["User Cache/Example", "User Cache/Example Gone"])
        #expect(items.dropFirst().map { library.relativePath(of: $0.url) } == ["User Cache/Example"])
    }

    private func plan(in library: TemporaryLibrary, foundByName paths: [String]) throws -> [RemovalItem] {
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        return RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [], foundByName: paths.map { library.url.appending(path: $0) })
    }
}
