import ClaudeKit
import Foundation

/// A running `claude` command that a chat talks to: prompts and approval answers are written to it as lines, and every line it prints is read back as events. It gets a PATH with the usual install folders, because an app opened from Finder has almost none, and the tools Claude runs, such as `git`, need it.
final class ClaudeProcess {
    private static let searchPath = ["~/.local/bin", "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin"]

    private let process = Process()
    private let input = Pipe()
    private let output = Pipe()

    init?(command: URL, arguments: [String], folder: URL, onEvents: @escaping ([ClaudeEvent]) -> Void, onExit: @escaping @MainActor () -> Void) {
        signal(SIGPIPE, SIG_IGN)
        process.executableURL = command
        process.arguments = arguments
        process.currentDirectoryURL = folder
        process.environment = Self.environment
        process.standardInput = input
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        process.terminationHandler = { _ in Task { @MainActor in onExit() } }
        guard (try? process.run()) != nil else { return nil }
        let lines = output.fileHandleForReading.bytes.lines
        Task {
            for try await line in lines {
                onEvents(ClaudeEventParser.events(in: line))
            }
        }
    }

    func send(_ line: Data) -> Bool {
        (try? input.fileHandleForWriting.write(contentsOf: line)) != nil
    }

    func end() {
        try? input.fileHandleForWriting.close()
        process.terminate()
    }

    private static var environment: [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        environment["PATH"] = searchPath.map { $0.replacingOccurrences(of: "~", with: home) }.joined(separator: ":")
        return environment
    }
}
