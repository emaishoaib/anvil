import AppKit
import ClaudeKit
import Observation

/// One chat in AI mode, from before its first prompt is sent until it is left: the prompt being typed, an image waiting to go with it, the session once there is one, whether it is saved into Claude desktop, the question asked before leaving, the name being typed while renaming, and the skills offered after a slash. Leaving saves the chat into Claude desktop or moves its files to the Trash, and then tells whoever holds the chat, passing on any prompt that was waiting to start a new chat.
@Observable final class ChatModel {
    let setup: ChatSetup
    let signIn: ClaudeSignIn
    let update: ClaudeUpdate
    let slashCommands = SlashCommandPicker()
    private(set) var session: ClaudeChatSession?
    private(set) var question: ChatQuestion? {
        didSet { highlightedChoice = nil }
    }
    private(set) var isSaved: Bool
    var nameDraft: String?
    var prompt = "" {
        didSet { slashCommands.update(for: prompt, in: folder) }
    }
    /// A PNG image, such as a screenshot, that goes with the next prompt sent from the field and is then let go.
    private(set) var attachedImage: Data?
    private var highlightedChoice: CardChoice?
    @ObservationIgnored private var promptAfterLeaving: String?
    @ObservationIgnored var onLeave: (_ waitingPrompt: String?) -> Void = { _ in }

    init(setup: ChatSetup, signIn: ClaudeSignIn, update: ClaudeUpdate) {
        self.setup = setup
        self.signIn = signIn
        self.update = update
        isSaved = false
    }

    init(resuming desktopSession: DesktopSession, setup: ChatSetup, signIn: ClaudeSignIn, update: ClaudeUpdate) {
        self.setup = setup
        self.signIn = signIn
        self.update = update
        session = ClaudeChatSession(resuming: desktopSession, update: update)
        isSaved = true
    }

    var isStarted: Bool { session != nil }

    var folder: URL { session?.folder ?? setup.folder }

    var isPromptEmpty: Bool {
        prompt.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// The field's hint, left out while a loaded chat's earlier turns are still being read, so nothing reads as ready to type into before the chat shows.
    var placeholder: String {
        session?.isLoadingHistory == true ? "" : SearchMode.askClaude.placeholder
    }

    var state: ChatState {
        if let session {
            if !session.approvals.isEmpty { return .awaitingApproval }
            if session.isAnswering { return .answering }
            switch update.state {
            case .needed, .failed: return .outdated
            case .updating: return .updating
            case .notNeeded: break
            }
            return switch question {
            case .leave: .askingToLeave
            case nil: .started
            }
        }
        return switch signIn.state {
        case .signedOut: .signedOut
        case .signingIn: .signingIn
        case .signedIn, .unknown: .notStarted
        }
    }

    func loadHistory(showingAfter wait: Duration = .zero) async {
        await session?.loadHistory(showingAfter: wait)
    }

    func attach(_ png: Data) {
        attachedImage = png
    }

    func removeAttachedImage() {
        attachedImage = nil
    }

    /// Sends the prompt in the field with any image attached, so an image can go on its own without any text.
    func sendPrompt() {
        let text = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || attachedImage != nil, canSend else { return NSSound.beep() }
        send(text, image: attachedImage)
        prompt = ""
        attachedImage = nil
    }

    /// Sends the prompt, unless Claude is still answering or Claude Code is being updated, in which case it waits in the field.
    func sendOrHold(_ text: String) {
        guard canSend else {
            prompt = text
            return
        }
        send(text)
    }

    private var canSend: Bool {
        session?.isAnswering != true && update.state != .updating
    }

    private func send(_ text: String, image: Data? = nil) {
        let session = session ?? ClaudeChatSession(folder: setup.folder, update: update)
        self.session = session
        update.forget()
        session.send(text, image: image, mode: setup.mode)
    }

    /// Signs Claude Code in, and once it is signed in, sends the prompt or image waiting in the field, if there is one.
    func signInToClaude() {
        signIn.signIn { [weak self] in
            guard let self, !isPromptEmpty || attachedImage != nil else { return }
            sendPrompt()
        }
    }

    /// Updates Claude Code, and once it is updated, sends again the prompt that found it too old, with its image if it had one.
    func updateClaude() {
        update.update { [weak self] in
            guard let self, let turn = session?.turns.last, canSend else { return }
            send(turn.prompt, image: turn.image)
        }
    }

    func stop() {
        session?.stop()
    }

    /// Leaves straight away when the chat is saved or nothing was sent yet, and otherwise asks first.
    func leave() {
        guard isStarted else { return finishLeaving() }
        guard !isSaved else { return save() }
        question = .leave
    }

    /// Leaves as `leave()` does, and passes the prompt on once the chat is left, so a new chat can start with it. If chatting goes on instead, the prompt moves into the field to send here.
    func leave(thenSending text: String) {
        promptAfterLeaving = text
        leave()
    }

    func keepChatting() {
        question = nil
        if let promptAfterLeaving { prompt = promptAfterLeaving }
        promptAfterLeaving = nil
    }

    /// Saves the chat into Claude desktop, so leaving it no longer asks. Before the first prompt there is nothing for Claude desktop to take yet, so it is saved when the chat is left.
    func startSaving() {
        isSaved = true
        if let session { ClaudeDesktop.save(session.sessionID) }
    }

    func save() {
        guard let session else { return }
        ClaudeDesktop.save(session.sessionID)
        session.end()
        finishLeaving()
    }

    /// Whether the chat can carry on in Claude desktop, which needs a first prompt sent and no question waiting on an answer here.
    var canMoveToClaudeDesktop: Bool {
        state == .started || state == .answering
    }

    /// Opens the chat in Claude desktop and leaves it, once Claude has finished any answer it is giving, or straight away when Claude is idle. Claude desktop saves the chat as it takes it, so leaving only lets Claude Code go here.
    func moveToClaudeDesktop() {
        guard canMoveToClaudeDesktop, let session else { return NSSound.beep() }
        Task {
            await ClaudeDesktop.open(session.sessionID)
            for await isAnswering in Observations({ session.isAnswering }) where !isAnswering { break }
            guard question == nil else { return }
            isSaved = true
            session.end()
            finishLeaving()
        }
    }

    func discard() {
        guard let session else { return }
        Task { await session.discard() }
        finishLeaving()
    }

    /// Lets Claude Code go without saving or discarding anything, as when the search bar starts afresh.
    func end() {
        session?.end()
    }

    private func finishLeaving() {
        let waiting = promptAfterLeaving
        question = nil
        promptAfterLeaving = nil
        nameDraft = nil
        onLeave(waiting)
    }

    /// Puts the selected skill or command in the prompt, followed by a space so anything after it can be typed straight away, which also closes the list.
    func completeSlashCommand() {
        guard let command = slashCommands.selectedCommand else { return }
        prompt = "/\(command.name) "
    }

    func dismissSlashCommands() {
        slashCommands.dismiss(prompt: prompt)
    }

    func startRenaming() {
        guard let session else { return }
        nameDraft = session.title
    }

    /// Gives the chat the name being typed, unless it was left empty or unchanged.
    func rename() {
        guard let session, let name = nameDraft?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        nameDraft = nil
        guard !name.isEmpty, name != session.title else { return }
        session.rename(to: name)
    }

    func cancelRenaming() {
        nameDraft = nil
    }

    /// The buttons of the question card at the end of the chat, left to right, or none when no card is asking.
    var cardChoices: [CardChoice] {
        switch state {
        case .awaitingApproval: CardChoice.approving
        case .askingToLeave: CardChoice.leaving
        default: []
        }
    }

    /// The button Return presses on the question card, which is the rightmost one until the arrows move the highlight.
    var cardChoice: CardChoice? {
        guard let highlightedChoice, cardChoices.contains(highlightedChoice) else { return cardChoices.last }
        return highlightedChoice
    }

    func moveCardChoice(by offset: Int) -> Bool {
        guard let cardChoice, let index = cardChoices.firstIndex(of: cardChoice) else { return false }
        highlightedChoice = cardChoices[min(max(index + offset, 0), cardChoices.count - 1)]
        return true
    }

    func chooseCardChoice() -> Bool {
        guard let cardChoice else { return false }
        choose(cardChoice)
        return true
    }

    func choose(_ choice: CardChoice) {
        highlightedChoice = nil
        switch choice {
        case .keepChatting: keepChatting()
        case .saveAndLeave: save()
        case .leave: discard()
        case .deny: session?.answerApproval(allowed: false)
        case .allow: session?.answerApproval(allowed: true)
        }
    }
}
