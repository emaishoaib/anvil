import Foundation
@testable import CleanerKit

/// A Library made in the temporary folder for one test. It holds an empty file at each path it is given, and is removed when the test lets go of it.
final class TemporaryLibrary {
    let url = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)

    init(_ paths: String...) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        for path in paths {
            let file = url.appending(path: path)
            try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            FileManager.default.createFile(atPath: file.path(percentEncoded: false), contents: nil)
        }
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    func leftoverPaths(of bundleID: String, named name: String = "Example", otherInstalledBundleIDs: Set<String> = []) -> [String] {
        let app = AppIdentity(bundleID: bundleID, name: name)
        return LeftoverSearch.leftovers(of: app, inLibrary: url, otherInstalledBundleIDs: otherInstalledBundleIDs)
            .map { "\($0.folder.rawValue)/\($0.url.lastPathComponent)" }
    }
}
