import Foundation
import Testing
@testable import CleanerKit

struct NativeMessagingHostsTests {
    func leftoverPaths(in library: TemporaryLibrary, forAppAt app: URL) -> [String] {
        RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: []).dropFirst().map { library.relativePath(of: $0.url) }
    }

    @Test func filesNamingAProgramInsideTheAppAreFoundOneAndTwoLevelsDown() throws {
        let library = try TemporaryLibrary()
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let program = app.appending(path: "Contents/Library/LoginItems/Browser Helper.app/Contents/MacOS/BrowserSupport")
        try library.writeHostFile(to: "Application Support/Mozilla/NativeMessagingHosts/com.acme.example.json", program: program)
        try library.writeHostFile(to: "Application Support/Google/Chrome/NativeMessagingHosts/com.acme.example.json", program: program)
        #expect(leftoverPaths(in: library, forAppAt: app) == [
            "Application Support/Google/Chrome/NativeMessagingHosts/com.acme.example.json",
            "Application Support/Mozilla/NativeMessagingHosts/com.acme.example.json",
        ])
    }

    @Test func aFileNamingAProgramInsideALeftoverFolderIsFound() throws {
        let library = try TemporaryLibrary("Application Support/Example/browser-host")
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        try library.writeHostFile(to: "Application Support/Mozilla/NativeMessagingHosts/com.acme.host.json", program: library.url.appending(path: "Application Support/Example/browser-host"))
        #expect(leftoverPaths(in: library, forAppAt: app) == [
            "Application Support/Example",
            "Application Support/Mozilla/NativeMessagingHosts/com.acme.host.json",
        ])
    }

    @Test func aFileNamingAnotherAppsProgramIsLeftAlone() throws {
        let library = try TemporaryLibrary()
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        let otherApp = try library.addApp(named: "Example Old", bundleID: "com.acme.old")
        try library.writeHostFile(to: "Application Support/Mozilla/NativeMessagingHosts/com.acme.old.json", program: otherApp.appending(path: "Contents/MacOS/Host"))
        #expect(leftoverPaths(in: library, forAppAt: app).isEmpty)
    }

    @Test func aFileInsideALeftoverFolderIsNotListedTwice() throws {
        let library = try TemporaryLibrary()
        let app = try library.addApp(named: "Example", bundleID: "com.acme.example")
        try library.writeHostFile(to: "Application Support/Example/NativeMessagingHosts/com.acme.example.json", program: app.appending(path: "Contents/MacOS/Host"))
        #expect(leftoverPaths(in: library, forAppAt: app) == ["Application Support/Example"])
    }
}
