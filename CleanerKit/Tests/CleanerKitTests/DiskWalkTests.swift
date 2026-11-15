import Foundation
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

    /// The paths the walk visits inside the Library, sorted. The step for each one is decided from its path.
    private func visitedPaths(in library: TemporaryLibrary, step: (String) -> DiskWalk.Step = { _ in .goInside }) -> [String] {
        var visited: [String] = []
        DiskWalk.walk([library.url]) { item in
            let path = library.relativePath(of: item)
            visited.append(path)
            return step(path)
        }
        return visited.sorted()
    }
}
