import ClaudeKit
import Foundation
import Observation

/// A chat with Claude Code in one folder and permission mode, which stay fixed for the whole chat. Claude Code starts with the first prompt and keeps running between prompts, so each follow-up continues the same conversation, saved under this chat's session id. Approvals Claude asks for wait in line and are answered one at a time, oldest first. Stopping an answer asks Claude Code to stop, and if it has not finished a few seconds later, the answer counts as stopped anyway.
@Observable final class ClaudeChatSession {
    private static let stoppedUnexpectedly = "Claude Code stopped before it finished answering."
    private static let notInstalled = "Anvil could not find Claude Code. Install it from claude.com/claude-code."
    private static let stopGrace = Duration.seconds(3)

    let sessionID = UUID()
    let folder: URL
    let mode: PermissionMode
    private(set) var transcript = ChatTranscript()
    private(set) var approvals: [Approval] = []
    @ObservationIgnored private var process: ClaudeProcess?
    @ObservationIgnored private var isStopping = false

    var turns: [ChatTurn] { transcript.turns }
    var isAnswering: Bool { transcript.isAnswering }
    var title: String { transcript.title }

    init(folder: URL, mode: PermissionMode) {
        self.folder = folder
        self.mode = mode
    }

    func send(_ prompt: String) {
        guard !isAnswering else { return }
        transcript.start(prompt)
        guard let command = ClaudeCommand.url else { return finish(answer: Self.notInstalled, failed: true) }
        guard let process = process ?? start(command), process.send(ClaudePrompt.line(prompt)) else { return finish(answer: Self.stoppedUnexpectedly, failed: true) }
    }

    func answerApproval(allowed: Bool) {
        guard let approval = approvals.first else { return }
        approvals.removeFirst()
        if process?.send(ApprovalAnswer.line(for: approval, allowed: allowed)) != true { finish(answer: Self.stoppedUnexpectedly, failed: true) }
    }

    func stop() {
        guard isAnswering, !isStopping else { return }
        isStopping = true
        approvals.removeAll()
        guard process?.send(ClaudeInterrupt.line()) == true else { return finishStopping() }
        Task { [weak self] in
            try? await Task.sleep(for: Self.stopGrace)
            self?.finishStopping()
        }
    }

    func end() {
        let process = process
        self.process = nil
        Task { await process?.end() }
    }

    func discard() async {
        let process = process
        self.process = nil
        await process?.end()
        ClaudeSessionFiles.trash(sessionID)
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
            case .text(let text): transcript.addText(text)
            case .finished(let answer, let failed): finish(answer: answer, failed: failed)
            case .toolStarted(let call): transcript.startTool(call)
            case .toolFinished(let id, let failed): transcript.finishTool(id, failed: failed)
            case .approvalRequested(let approval): approvals.append(approval)
            case .approvalWithdrawn(let requestID): approvals.removeAll { $0.requestID == requestID }
            case .started: break
            }
        }
    }

    private func finish(answer: String, failed: Bool) {
        guard !isStopping else { return finishStopping() }
        approvals.removeAll()
        transcript.finish(answer: answer, failed: failed)
    }

    private func finishStopping() {
        guard isStopping else { return }
        isStopping = false
        transcript.markStopped()
    }

    private func stopped() {
        process = nil
        guard isAnswering else { return }
        finish(answer: Self.stoppedUnexpectedly, failed: true)
    }
}
