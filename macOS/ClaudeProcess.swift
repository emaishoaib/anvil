import ClaudeKit
import Foundation

/// A running `claude` command that a chat talks to: prompts and approval answers are written to it as lines, and every line it prints is read back as events.
final class ClaudeProcess {
    private let process = Process()
    private let input = Pipe()
    private let output = Pipe()

    init?(command: URL, arguments: [String], folder: URL, onEvents: @escaping ([ClaudeEvent]) -> Void, onExit: @escaping @MainActor () -> Void) {
        signal(SIGPIPE, SIG_IGN)
        process.executableURL = command
        process.arguments = arguments
        process.currentDirectoryURL = folder
        process.environment = ClaudeCommand.environment
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
}
