import Foundation
@testable import CleanerKit

/// A Library made in the temporary folder for one test. It holds an empty file at each path it is given, and is removed when the test lets go of it. Its `User Cache` and `User Temp` folders stand in for the per-user cache and temp folders under `/var/folders`, and its `Home` folder for the home folder.
final class TemporaryLibrary {
    let url = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)

    var roots: SearchRoots {
        SearchRoots(home: url.appending(path: "Home", directoryHint: .isDirectory), library: url, userCache: url.appending(path: "User Cache", directoryHint: .isDirectory), userTemp: url.appending(path: "User Temp", directoryHint: .isDirectory))
    }

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

    /// Writes a browser's native messaging file at the given path, naming the given program as the one the browser runs.
    func writeHostFile(to path: String, program: URL) throws {
        let file = url.appending(path: path)
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONSerialization.data(withJSONObject: ["name": file.deletingPathExtension().lastPathComponent, "path": program.path(percentEncoded: false)]).write(to: file)
    }

    /// Makes an app bundle in an `Applications` folder beside the Library folders, with an Info.plist holding the bundle ID, the bundle name and the executable's name when there are ones. Each helper is a bundle at the given path inside the app's `Contents` folder, with the given bundle ID.
    func addApp(named name: String, bundleID: String?, bundleName: String? = nil, executableName: String? = nil, helpers: [String: String] = [:]) throws -> URL {
        let app = url.appending(path: "Applications/\(name).app", directoryHint: .isDirectory)
        try writeInfo(["CFBundleIdentifier": bundleID, "CFBundleName": bundleName, "CFBundleExecutable": executableName], inBundle: app)
        for (path, helperBundleID) in helpers {
            try writeInfo(["CFBundleIdentifier": helperBundleID], inBundle: app.appending(path: "Contents/\(path)", directoryHint: .isDirectory))
        }
        return app
    }

    /// The path of a file inside this Library, such as `Caches/com.example.app`. Both paths are resolved first, because a walk of the Library gives back its `/var` paths as `/private/var`.
    func relativePath(of file: URL) -> String {
        let libraryPath = url.resolvingSymlinksInPath().path(percentEncoded: false)
        return String(file.resolvingSymlinksInPath().path(percentEncoded: false).dropFirst(libraryPath.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func writeInfo(_ keys: [String: String?], inBundle bundle: URL) throws {
        let info = bundle.appending(path: "Contents/Info.plist")
        try FileManager.default.createDirectory(at: info.deletingLastPathComponent(), withIntermediateDirectories: true)
        try PropertyListSerialization.data(fromPropertyList: keys.compactMapValues { $0 }, format: .xml, options: 0).write(to: info)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    func leftoverPaths(of bundleID: String, named name: String = "Example", otherNames: Set<String> = [], appGroups: Set<String> = [], otherInstalledBundleIDs: Set<String> = []) -> [String] {
        let app = AppIdentity(bundleID: bundleID, name: name, otherNames: otherNames, appGroups: appGroups)
        return LeftoverSearch.leftovers(of: app, in: roots, otherInstalledBundleIDs: otherInstalledBundleIDs).map { relativePath(of: $0.url) }
    }
}
