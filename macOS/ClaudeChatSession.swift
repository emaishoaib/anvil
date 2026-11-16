import ClaudeKit
import Foundation
import Observation

/// A chat with Claude Code in one folder and permission mode, which stay fixed for the whole chat. Claude Code starts with the first prompt and keeps running between prompts, so each follow-up continues the same conversation, saved under this chat's session id. Approvals Claude asks for wait in line and are answered one at a time, oldest first.
@Observable final class ClaudeChatSession {
    private static let stoppedUnexpectedly = "Claude Code stopped before it finished answering."
    private static let notInstalled = "Anvil could not find Claude Code. Install it from claude.com/claude-code."

    let sessionID = UUID()
    let folder: URL
    let mode: PermissionMode
    private(set) var turns: [ChatTurn] = []
    private(set) var approvals: [Approval] = []
    @ObservationIgnored private var process: ClaudeProcess?

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
        guard let process = process ?? start(command), process.send(ClaudePrompt.line(prompt)) else { return finish(answer: Self.stoppedUnexpectedly, failed: true) }
    }

    func answerApproval(allowed: Bool) {
        guard let approval = approvals.first else { return }
        approvals.removeFirst()
        if process?.send(ApprovalAnswer.line(for: approval, allowed: allowed)) != true { finish(answer: Self.stoppedUnexpectedly, failed: true) }
    }

    func end() {
        process?.end()
        process = nil
    }

    private func start(_ command: URL) -> ClaudeProcess? {
        process = ClaudeProcess(
            command: command,
            arguments: ClaudeArguments.chat(sessionID: sessionID, mode: mode),
            folder: folder,
            onEvents: { [weak self] in self?.apply($0) },
            onExit: { [weak self] in self?.stopped() }
        )
        return process
    }

    private func apply(_ events: [ClaudeEvent]) {
        for event in events {
            switch event {
            case .text(let text): updateLastTurn { $0.answer += text }
            case .finished(let answer, let failed): finish(answer: answer, failed: failed)
            case .toolStarted(let call): startTool(call)
            case .toolFinished(let id, let failed): finishTool(id, failed: failed)
            case .approvalRequested(let approval): approvals.append(approval)
            case .approvalWithdrawn(let requestID): approvals.removeAll { $0.requestID == requestID }
            case .started: break
            }
        }
    }

    private func startTool(_ call: ToolCall) {
        updateLastTurn { turn in
            turn.tools.append(ChatTool(id: call.id, summary: call.summary))
            if !turn.answer.isEmpty, !turn.answer.hasSuffix("\n") { turn.answer += "\n\n" }
        }
    }

    private func finishTool(_ id: String, failed: Bool) {
        updateLastTurn { turn in
            guard let index = turn.tools.firstIndex(where: { $0.id == id }) else { return }
            turn.tools[index].state = failed ? .failed : .finished
        }
    }

    private func finish(answer: String, failed: Bool) {
        approvals.removeAll()
        updateLastTurn { turn in
            if turn.answer.isEmpty || failed, !answer.isEmpty { turn.answer = answer }
            turn.isFinished = true
            turn.failed = failed
        }
    }

    private func stopped() {
        process = nil
        guard isAnswering else { return }
        finish(answer: Self.stoppedUnexpectedly, failed: true)
    }

    private func updateLastTurn(_ change: (inout ChatTurn) -> Void) {
        guard !turns.isEmpty else { return }
        change(&turns[turns.count - 1])
    }

}
