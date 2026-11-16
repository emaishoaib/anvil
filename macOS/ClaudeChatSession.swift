import ClaudeKit
import Foundation
import Observation

/// A chat with Claude Code in one folder and permission mode, which stay fixed for the whole chat. Claude Code starts with the first prompt and keeps running between prompts, so each follow-up continues the same conversation, saved under this chat's session id.
@Observable final class ClaudeChatSession {
    private static let searchPath = ["~/.local/bin", "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin"]
    private static let stoppedUnexpectedly = "Claude Code stopped before it finished answering."
    private static let notInstalled = "Anvil could not find Claude Code. Install it from claude.com/claude-code."

    let sessionID = UUID()
    let folder: URL
    let mode: PermissionMode
    private(set) var turns: [ChatTurn] = []
    @ObservationIgnored private var process: Process?
    @ObservationIgnored private var input: FileHandle?

    var isAnswering: Bool {
        turns.last.map { !$0.isFinished } ?? false
    }

    init(folder: URL, mode: PermissionMode) {
        self.folder = folder
        self.mode = mode
    }

    func send(_ prompt: String) {
        guard !isAnswering else { return }
        turns.append(ChatTurn(id: turns.count, prompt: prompt))
        guard let command = ClaudeCommand.url else { return finish(answer: Self.notInstalled, failed: true) }
        guard let input = input ?? start(command) else { return finish(answer: Self.stoppedUnexpectedly, failed: true) }
        do { try input.write(contentsOf: ClaudePrompt.line(prompt)) } catch { finish(answer: Self.stoppedUnexpectedly, failed: true) }
    }

    func end() {
        try? input?.close()
        process?.terminate()
        input = nil
        process = nil
    }

    private func start(_ command: URL) -> FileHandle? {
        signal(SIGPIPE, SIG_IGN)
        let process = Process()
        let input = Pipe()
        let output = Pipe()
        process.executableURL = command
        process.arguments = ClaudeArguments.chat(sessionID: sessionID, mode: mode)
        process.currentDirectoryURL = folder
        process.environment = Self.environment
        process.standardInput = input
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        process.terminationHandler = { _ in Task { @MainActor [weak self] in self?.stopped() } }
        guard (try? process.run()) != nil else { return nil }
        self.process = process
        self.input = input.fileHandleForWriting
        read(output.fileHandleForReading)
        return input.fileHandleForWriting
    }

    private func read(_ output: FileHandle) {
        Task { [weak self] in
            for try await line in output.bytes.lines {
                self?.apply(ClaudeEventParser.events(in: line))
            }
        }
    }

    private func apply(_ events: [ClaudeEvent]) {
        for event in events {
            switch event {
            case .text(let text): updateLastTurn { $0.answer += text }
            case .finished(let answer, let failed): finish(answer: answer, failed: failed)
            case .started, .toolStarted, .toolFinished: break
            }
        }
    }

    private func finish(answer: String, failed: Bool) {
        updateLastTurn { turn in
            if turn.answer.isEmpty || failed, !answer.isEmpty { turn.answer = answer }
            turn.isFinished = true
            turn.failed = failed
        }
    }

    private func stopped() {
        input = nil
        process = nil
        guard isAnswering else { return }
        finish(answer: Self.stoppedUnexpectedly, failed: true)
    }

    private func updateLastTurn(_ change: (inout ChatTurn) -> Void) {
        guard !turns.isEmpty else { return }
        change(&turns[turns.count - 1])
    }

    private static var environment: [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        environment["PATH"] = searchPath.map { $0.replacingOccurrences(of: "~", with: home) }.joined(separator: ":")
        return environment
    }
}
