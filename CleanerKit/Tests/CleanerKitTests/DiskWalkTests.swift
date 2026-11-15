import Foundation
import Synchronization
import Testing
@testable import CleanerKit

struct DiskWalkTests {
    @Test func everyFileAndFolderUnderTheGivenFolderIsVisited() throws {
        let library = try TemporaryLibrary("Caches/Example/data.db", "Logs/Example.log")
        #expect(visitedPaths(in: library) == ["Caches", "Caches/Example", "Caches/Example/data.db", "Logs", "Logs/Example.log"])
    }

    @Test func aBundleIsVisitedButNotWhatIsInsideIt() throws {
        let library = try TemporaryLibrary("Applications/Example.app/Contents/Info.plist", "SDKs/MacOSX.sdk/Headers/Example.h")
        #expect(visitedPaths(in: library) == ["Applications", "Applications/Example.app", "SDKs", "SDKs/MacOSX.sdk"])
    }

    @Test func aPackageThatIsNotABundleIsVisitedButNotWhatIsInsideIt() throws {
        let library = try TemporaryLibrary("Pictures/Photos Library.photoslibrary/database/Photos.sqlite")
        #expect(visitedPaths(in: library) == ["Pictures", "Pictures/Photos Library.photoslibrary"])
    }

    @Test func aTrashFolderIsVisitedButNotWhatIsInsideIt() throws {
        let library = try TemporaryLibrary("Users/me/.Trash/Example/data.db", "Users/me/notes.txt")
        #expect(visitedPaths(in: library) == ["Users", "Users/me", "Users/me/.Trash", "Users/me/notes.txt"])
    }

    @Test func aFolderTheVisitorStaysOutsideOfIsVisitedButNotWhatIsInsideIt() throws {
        let library = try TemporaryLibrary("Caches/Example/data.db", "Logs/Example.log")
        let visited = visitedPaths(in: library) { $0 == "Caches" ? .stayOutside : .goInside }
        #expect(visited == ["Caches", "Logs", "Logs/Example.log"])
    }

    @Test func aFolderThatDoesNotExistGivesNothing() {
        let missing = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        var visitCount = 0
        DiskWalk.walk([missing]) { _ in
            visitCount += 1
            return .goInside
        }
        #expect(visitCount == 0)
    }

    @Test func walkingSideBySideVisitsWhatWalkingInOneGoVisits() throws {
        let library = try TemporaryLibrary("Users/me/Library/Caches/Example/data.db", "Users/me/Library/Logs/Example.log", "Users/me/notes.txt", "Applications/Example.app/Contents/Info.plist")
        let visited = Mutex<[URL]>([])
        DiskWalk.walkSideBySide([library.url]) { item in
            visited.withLock { $0.append(item.url) }
            return .goInside
        }
        #expect(visited.withLock { $0 }.map(library.relativePath(of:)).sorted() == visitedPaths(in: library))
    }

    @Test func walkingSideBySideStaysOutsideABundleOrAFolderTheVisitorStaysOutsideOfAtAnyLevel() throws {
        let library = try TemporaryLibrary("Users/me/Library/Example.app/Contents/Info.plist", "Users/me/Library/Caches/Example/data.db", "Users/me/Library/Logs/Other.log")
        let visited = Mutex<[URL]>([])
        DiskWalk.walkSideBySide([library.url]) { item in
            visited.withLock { $0.append(item.url) }
            return item.name == "Caches" ? .stayOutside : .goInside
        }
        #expect(visited.withLock { $0 }.map(library.relativePath(of:)).sorted() == ["Users", "Users/me", "Users/me/Library", "Users/me/Library/Caches", "Users/me/Library/Example.app", "Users/me/Library/Logs", "Users/me/Library/Logs/Other.log"])
    }

    /// The paths the walk visits inside the Library, sorted. The step for each one is decided from its path.
    private func visitedPaths(in library: TemporaryLibrary, step: (String) -> DiskWalk.Step = { _ in .goInside }) -> [String] {
        var visited: [String] = []
        DiskWalk.walk([library.url]) { item in
            let path = library.relativePath(of: item.url)
            visited.append(path)
            return step(path)
        }
        return visited.sorted()
    }
}
