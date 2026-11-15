import Foundation
@testable import CleanerKit

/// A Library made in the temporary folder for one test. It holds an empty file at each path it is given, and is removed when the test lets go of it.
final class TemporaryLibrary {
    let url = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)

    init(_ paths: String...) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        for path in paths {
            try write(byteCount: 0, to: path)
        }
    }

    func write(byteCount: Int, to path: String) throws {
        let file = url.appending(path: path)
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(count: byteCount).write(to: file)
    }

    /// Makes an app bundle in an `Applications` folder beside the Library folders, with an Info.plist holding the bundle ID when there is one. Each helper is a bundle at the given path inside the app's `Contents` folder, with the given bundle ID.
    func addApp(named name: String, bundleID: String?, helpers: [String: String] = [:]) throws -> URL {
        let app = url.appending(path: "Applications/\(name).app", directoryHint: .isDirectory)
        try writeInfo(bundleID: bundleID, inBundle: app)
        for (path, helperBundleID) in helpers {
            try writeInfo(bundleID: helperBundleID, inBundle: app.appending(path: "Contents/\(path)", directoryHint: .isDirectory))
        }
        return app
    }

    private func writeInfo(bundleID: String?, inBundle bundle: URL) throws {
        let info = bundle.appending(path: "Contents/Info.plist")
        try FileManager.default.createDirectory(at: info.deletingLastPathComponent(), withIntermediateDirectories: true)
        let plist = bundleID.map { ["CFBundleIdentifier": $0] } ?? [:]
        try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0).write(to: info)
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
