import Testing
@testable import CleanerKit

struct CrashReportMatchTests {
    let hardwareID = "ADC4BFBE-B5AB-502B-BE84-8760F2526795"

    @Test func theFileNamedAfterTheAppOrItsExecutableIsFound() throws {
        let library = try TemporaryLibrary(
            "Application Support/CrashReporter/Visual Studio Code_\(hardwareID).plist",
            "Application Support/CrashReporter/code_\(hardwareID).plist"
        )
        #expect(library.leftoverPaths(of: "com.acme.code", named: "Visual Studio Code", executableName: "Code") == [
            "Application Support/CrashReporter/Visual Studio Code_\(hardwareID).plist",
            "Application Support/CrashReporter/code_\(hardwareID).plist",
        ])
    }

    @Test func aFileForAProgramWhoseNameOnlyStartsWithTheAppsIsLeftAlone() throws {
        let library = try TemporaryLibrary(
            "Application Support/CrashReporter/Example Helper_\(hardwareID).plist",
            "Application Support/CrashReporter/OtherExample_\(hardwareID).plist",
            "Application Support/CrashReporter/Example_\(hardwareID).txt"
        )
        #expect(library.leftoverPaths(of: "com.acme.example").isEmpty)
    }

    @Test func anExecutableNameAnotherInstalledAppGoesByIsLeftToThatApp() throws {
        let library = try TemporaryLibrary("Application Support/CrashReporter/Claude_\(hardwareID).plist")
        let handler = try library.addApp(named: "Claude Code URL Handler", bundleID: "com.acme.handler", executableName: "claude")
        let app = try library.addApp(named: "Claude", bundleID: "com.acme.claude", executableName: "Claude")
        #expect(RemovalPlan.items(forAppAt: handler, in: library.roots, otherAppURLs: [app]).map(\.kind) == [.app])
        #expect(RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [handler]).count == 2)
    }

    @Test func theExecutableNameIsReadFromTheApp() throws {
        let library = try TemporaryLibrary("Application Support/CrashReporter/Code_\(hardwareID).plist")
        let app = try library.addApp(named: "Visual Studio Code", bundleID: "com.acme.code", executableName: "Code")
        let items = RemovalPlan.items(forAppAt: app, in: library.roots, otherAppURLs: [])
        #expect(items.dropFirst().map { library.relativePath(of: $0.url) } == ["Application Support/CrashReporter/Code_\(hardwareID).plist"])
    }
}
