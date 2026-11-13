import Foundation
import Testing
@testable import LauncherKit

final class AppScannerTests {
    let folder = FileManager.default.temporaryDirectory.appending(path: "AppScannerTests-\(UUID().uuidString)")

    deinit {
        try? FileManager.default.removeItem(at: folder)
    }

    @discardableResult
    func make(_ path: String) throws -> URL {
        let url = folder.appending(path: path)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    func names(depth: Int = AppScanner.defaultDepth) -> Set<String> {
        Set(AppScanner.apps(in: folder, depth: depth).map(\.lastPathComponent))
    }

    @Test func findsAppsInTheFolder() throws {
        try make("Safari.app")
        try make("Notes.txt")
        #expect(names() == ["Safari.app"])
    }

    @Test func findsAppsOneFolderDown() throws {
        try make("Utilities/Terminal.app")
        #expect(names() == ["Terminal.app"])
    }

    @Test func doesNotGoDeeperThanTheDepth() throws {
        try make("Vendor/Tools/Helper.app")
        #expect(names().isEmpty)
    }

    @Test func doesNotLookInsideApps() throws {
        try make("Xcode.app/Contents/Applications/Instruments.app")
        #expect(names() == ["Xcode.app"])
    }

    @Test func findsAppsThatAreHidden() throws {
        var app = try make("Safari.app")
        var values = URLResourceValues()
        values.isHidden = true
        try app.setResourceValues(values)
        #expect(names() == ["Safari.app"])
    }

    @Test func missingFolderHasNoApps() {
        #expect(names().isEmpty)
    }
}
