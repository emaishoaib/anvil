import ClaudeKit
import Foundation
import Observation

/// A chat with Claude Code in one folder, which stays fixed for the whole chat. Claude Code starts with the first prompt sent here, in the permission mode picked at that moment, and keeps running between prompts, so each follow-up continues the same conversation, saved under this chat's session id. A saved chat carried on later resumes that session, showing its earlier turns once they are read, and its mode can still change until the first new prompt. Approvals Claude asks for wait in line and are answered one at a time, oldest first. Stopping an answer asks Claude Code to stop, and if it has not finished a few seconds later, the answer counts as stopped anyway. If Claude Code exits before it finishes an answer, the answer says so, followed by the last errors it printed, and when those show Claude Code is too old, the chat asks for it to be updated. A chat whose Claude Code never got as far as starting its session starts it afresh with the next prompt, rather than resuming a session that does not exist.
@Observable final class ClaudeChatSession {
    private static let stoppedUnexpectedly = "Claude Code stopped before it finished answering."
    private static let notInstalled = "Anvil could not find Claude Code. Install it from claude.com/claude-code."
    private static let stopGrace = Duration.seconds(3)

    let sessionID: UUID
    let folder: URL
    private(set) var mode: PermissionMode?
    private(set) var transcript = ChatTranscript()
    private(set) var approvals: [Approval] = []
    private(set) var isLoadingHistory = false
    @ObservationIgnored private var process: ClaudeProcess?
    @ObservationIgnored private var isStopping = false
    @ObservationIgnored private var resumes: Bool
    private var savedTitle: String?
    @ObservationIgnored private var unwrittenTitle: String?
    @ObservationIgnored private let update: ClaudeUpdate

    var turns: [ChatTurn] { transcript.turns }
    var isAnswering: Bool { transcript.isAnswering }
    /// The name the chat was given, by renaming it or by Claude desktop for a loaded chat, or for a new chat its first prompt's first line, or its folder's name until a prompt is sent.
    var title: String { savedTitle ?? (transcript.title.isEmpty ? folder.lastPathComponent : transcript.title) }

    init(folder: URL, update: ClaudeUpdate) {
        self.folder = folder
        self.update = update
        sessionID = UUID()
        resumes = false
        savedTitle = nil
    }

    init(resuming session: DesktopSession, update: ClaudeUpdate) {
        folder = session.folder
        self.update = update
        sessionID = session.sessionID
        resumes = true
        isLoadingHistory = true
        savedTitle = session.title
    }

    /// Reads the earlier turns of a resumed chat from its transcript, away from the main thread, since a long chat's file can be large. They only show if no new prompt was sent in the meantime. A resumed chat counts as loading from the moment it is made until this finishes, however it finishes.
    func loadHistory() async {
        defer { isLoadingHistory = false }
        guard let file = ClaudeSessionFiles.transcript(of: sessionID) else { return }
        let turns = await Task.detached { (try? String(contentsOf: file, encoding: .utf8)).map(SessionHistory.turns) ?? [] }.value
        guard mode == nil else { return }
        transcript = ChatTranscript(past: turns)
    }

    func send(_ prompt: String, mode chosenMode: PermissionMode) {
        guard !isAnswering else { return }
        mode = mode ?? chosenMode
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

    /// Names the chat. The name is written to its transcript, and to Claude desktop's record when Claude desktop has the chat, once Claude Code is not writing an answer and the transcript exists, so a chat renamed before its first prompt gets its name after the first answer.
    func rename(to title: String) {
        savedTitle = title
        unwrittenTitle = title
        writeTitle()
    }

    private func writeTitle() {
        guard !isAnswering, let unwrittenTitle, let file = ClaudeSessionFiles.transcript(of: sessionID) else { return }
        ClaudeSessionFiles.append(TranscriptTitle.line(unwrittenTitle, sessionID: sessionID), to: file)
        DesktopSessionFiles.rename(sessionID, to: unwrittenTitle)
        self.unwrittenTitle = nil
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
        let mode = mode ?? .manual
        let arguments = resumes ? ClaudeArguments.resume(sessionID: sessionID, mode: mode) : ClaudeArguments.chat(sessionID: sessionID, mode: mode)
        process = ClaudeProcess(
            command: command,
            arguments: arguments,
            folder: folder,
            onEvents: { [weak self] in self?.apply($0) },
            onExit: { [weak self] in self?.stopped(printing: $0) }
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
            case .started: resumes = true
            }
        }
    }

    private func finish(answer: String, failed: Bool) {
        guard !isStopping else { return finishStopping() }
        approvals.removeAll()
        transcript.finish(answer: answer, failed: failed)
        writeTitle()
    }

    private func finishStopping() {
        guard isStopping else { return }
        isStopping = false
        transcript.markStopped()
        writeTitle()
    }

    private func stopped(printing errors: String) {
        process = nil
        guard isAnswering else { return }
        if OutdatedClaude.isOutdated(printing: errors) { update.need() }
        finish(answer: errors.isEmpty ? Self.stoppedUnexpectedly : "\(Self.stoppedUnexpectedly)\n\n\(errors)", failed: true)
    }
}
