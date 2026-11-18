import ClaudeKit
import Foundation

/// A running `claude` command that a chat talks to: prompts and approval answers are written to it as lines, and every line it prints is read back as events. The last few lines it prints as errors are kept and handed over once it exits, so a chat can say why it stopped. Those lines normally end when the command does, but a process it started could keep them open, so after a short wait they are handed over as they are. The errors are read as they arrive rather than through `FileHandle.bytes`, because every `bytes` read in the app waits in one shared line, and a read waiting for errors that never come would hold up the answer.
final class ClaudeProcess {
    private static let errorLinesKept = 5
    private static let errorGrace = Duration.milliseconds(500)

    private let process = Process()
    private let input = Pipe()
    private let output = Pipe()
    private let errors = Pipe()
    private var errorText = ""
    private var errorsEnded = false

    init?(command: URL, arguments: [String], folder: URL, onEvents: @escaping ([ClaudeEvent]) -> Void, onExit: @escaping @MainActor (String) -> Void) {
        signal(SIGPIPE, SIG_IGN)
        process.executableURL = command
        process.arguments = arguments
        process.currentDirectoryURL = folder
        process.environment = ClaudeCommand.environment
        process.standardInput = input
        process.standardOutput = output
        process.standardError = errors
        process.terminationHandler = { [weak self] _ in Task { @MainActor in onExit(await self?.lastErrors() ?? "") } }
        guard (try? process.run()) != nil else { return nil }
        let lines = output.fileHandleForReading.bytes.lines
        Task {
            for try await line in lines {
                onEvents(ClaudeEventParser.events(in: line))
            }
        }
        let errorChunks = Self.chunks(of: errors.fileHandleForReading)
        Task { [weak self] in
            for await chunk in errorChunks {
                self?.keepErrors(chunk)
            }
            self?.errorsEnded = true
        }
    }

    func send(_ line: Data) -> Bool {
        (try? input.fileHandleForWriting.write(contentsOf: line)) != nil
    }

    /// Stops Claude Code and waits until it has exited, so its files are no longer being written.
    func end() async {
        try? input.fileHandleForWriting.close()
        process.terminate()
        let process = process
        await Task.detached { process.waitUntilExit() }.value
    }

    /// What a file handle gives as it arrives, in order, ending when the other side closes it.
    private nonisolated static func chunks(of handle: FileHandle) -> AsyncStream<Data> {
        AsyncStream { continuation in
            handle.readabilityHandler = { handle in
                let chunk = handle.availableData
                guard !chunk.isEmpty else {
                    handle.readabilityHandler = nil
                    return continuation.finish()
                }
                continuation.yield(chunk)
            }
        }
    }

    private func keepErrors(_ chunk: Data) {
        errorText += String(decoding: chunk, as: UTF8.self)
        errorText = errorText.split(separator: "\n", omittingEmptySubsequences: false).suffix(Self.errorLinesKept + 1).joined(separator: "\n")
    }

    private func lastErrors() async -> String {
        if !errorsEnded { try? await Task.sleep(for: Self.errorGrace) }
        return errorText.split(separator: "\n").suffix(Self.errorLinesKept).joined(separator: "\n")
    }
}
