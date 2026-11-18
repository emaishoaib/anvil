import AppKit
import ClaudeKit
import LauncherKit
import Observation
import ShellKit

@Observable final class SearchModel {
    private(set) var mode = SearchMode.launcher
    var query = "" {
        didSet { refresh() }
    }
    private(set) var results: [SearchResult] = []
    private(set) var selected = 0
    private(set) var entryPage = ""
    var field = SearchField.query
    var arguments = LinkArguments()
    var draft = QuickLink()
    var quickLinkField = QuickLinkField.name
    var ruleDraft = RuleDraft()
    var keySwapDraft = KeySwapDraft()
    var aliasDraft = Alias(name: "", command: "")
    var aliasField = AliasField.name
    var shellTextDraft = ""
    private(set) var actionPanel: ActionPanel?
    private(set) var review: UninstallReview?
    private(set) var desktopSessionList: DesktopSessionList?
    private(set) var timesOpened = 0
    private(set) var isPinned = false
    let settings = SettingsBarModel()
    let chatSetup = ChatSetup()
    private(set) var chat: ClaudeChatSession?
    private(set) var chatQuestion: ChatQuestion? {
        didSet { highlightedChoice = nil }
    }
    private var highlightedChoice: CardChoice?
    private(set) var isChatSaved = false
    private var wantsExpanded = false
    private var promptAfterLeaving: String?

    var isExpanded: Bool {
        mode == .askClaude && wantsExpanded
    }
    let claudeSignIn = ClaudeSignIn()
    let claudeUpdate = ClaudeUpdate()

    var chatState: ChatState {
        if let chat {
            if !chat.approvals.isEmpty { return .awaitingApproval }
            if chat.isAnswering { return .answering }
            switch claudeUpdate.state {
            case .needed, .failed: return .outdated
            case .updating: return .updating
            case .notNeeded: break
            }
            return switch chatQuestion {
            case .leave: .askingToLeave
            case nil: .started
            }
        }
        return switch claudeSignIn.state {
        case .signedOut: .signedOut
        case .signingIn: .signingIn
        case .signedIn, .unknown: .notStarted
        }
    }
    @ObservationIgnored private var wordLookup: Task<Void, Never>?
    @ObservationIgnored private var launchCounts = SavedLaunchCounts.load()

    var selectedResult: SearchResult? {
        results.indices.contains(selected) ? results[selected] : nil
    }

    var resultsTitle: String {
        switch (mode, isQueryEmpty) {
        case (.defineWord, true): "Recent Words"
        case (.launcher, true): "Suggestions"
        case (.uninstallApp, _): "Apps"
        default: "Results"
        }
    }

    /// The field's hint for the current mode, left out while a loaded chat's earlier turns are still being read, so nothing reads as ready to type into before the chat shows.
    var placeholder: String {
        chat?.isLoadingHistory == true ? "" : mode.placeholder
    }

    var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func reset() {
        settings.finishEditing()
        endChat()
        wantsExpanded = false
        LeftoverIndexStore.shared.forget()
        launchCounts = SavedLaunchCounts.load()
        actionPanel = nil
        review = nil
        desktopSessionList = nil
        arguments = LinkArguments()
        draft = QuickLink()
        ruleDraft = RuleDraft()
        keySwapDraft = KeySwapDraft()
        aliasDraft = Alias(name: "", command: "")
        aliasField = .name
        shellTextDraft = ""
        entryPage = ""
        field = .query
        mode = .launcher
        query = ""
        timesOpened += 1
    }

    func reopen() {
        timesOpened += 1
    }

    func moveSelection(by offset: Int) {
        if mode == .settings { return settings.moveSelection(by: offset) }
        if case .uninstallReview = mode {
            review?.moveSelection(by: offset, matching: query)
            return
        }
        if mode == .desktopSessions {
            desktopSessionList?.moveSelection(by: offset, matching: query)
            return
        }
        guard !results.isEmpty else { return }
        selected = min(max(selected + offset, 0), results.count - 1)
        showArguments()
    }

    func moveFocus(by offset: Int) -> Bool {
        guard mode == .launcher, !arguments.placeholders.isEmpty else { return false }
        field = field.moved(by: offset, argumentCount: arguments.placeholders.count)
        return true
    }

    func moveFormFocus(by offset: Int) -> Bool {
        switch mode {
        case .quickLinkForm: quickLinkField = quickLinkField.moved(by: offset)
        case .aliasForm: aliasField = aliasField.moved(by: offset)
        default: return false
        }
        return true
    }

    func leaveArguments() -> Bool {
        guard field != .query else { return false }
        field = .query
        return true
    }

    func openSelected() {
        if mode == .askClaude { return sendPrompt() }
        if mode == .desktopSessions { return continueSelectedChat() }
        if mode == .settings {
            if let setting = settings.selectedSetting { open(setting) }
            return
        }
        if case .wordEntry(let word, _) = mode {
            WordLookup.openInDictionary(word)
            return SearchBar.shared.hide()
        }
        if case .uninstallReview = mode {
            review?.toggleSelected(matching: query)
            return
        }
        guard results.indices.contains(selected) else { return }
        open(results[selected])
    }

    func open(_ result: SearchResult) {
        switch result {
        case .answer(let answer):
            copy(answer.copyText)
            SearchBar.shared.hide()
        case .app(let app):
            guard mode != .uninstallApp else { return showReview(of: app) }
            launch(app)
            SearchBar.shared.hide(remembering: false)
        case .command(let command):
            run(command)
        case .quickLink(let link):
            if let index = results.firstIndex(of: result), index != selected {
                selected = index
                showArguments()
            }
            if let blank = arguments.firstBlank {
                field = .argument(blank)
                return
            }
            open(link, filling: arguments.values, in: link.openWith)
            SearchBar.shared.hide(remembering: false)
        case .word(let word):
            SavedRecentWords.record(word.text)
            entryPage = DictionaryEntries.page(for: word.text)
            mode = .wordEntry(word, query: query)
            query = ""
        }
    }

    func open(_ setting: Setting) {
        settings.finishEditing()
        settings.select(setting)
        guard !setting.isDisabled else { return settings.activate(setting) }
        switch setting.row {
        case .choice: showPanel(for: .settingChoices(setting))
        case .rule(let rule): showPanel(for: .rule(rule))
        default: settings.activate(setting)
        }
    }

    func showRuleForm(_ draft: RuleDraft, in group: RuleGroup, isNew: Bool) {
        settings.finishEditing()
        ruleDraft = draft
        mode = .ruleForm(group, isNew: isNew, query: query)
        query = ""
    }

    func showKeySwapForm() {
        settings.finishEditing()
        keySwapDraft = KeySwapDraft()
        mode = .keySwapForm(query: query)
        query = ""
    }

    func showAliasForm() {
        settings.finishEditing()
        aliasDraft = Alias(name: "", command: "")
        aliasField = .name
        mode = .aliasForm(query: query)
        query = ""
    }

    func showShellTextForm(_ text: ShellText) {
        settings.finishEditing()
        shellTextDraft = text.current
        mode = .shellTextForm(text, query: query)
        query = ""
    }

    func clearSelectedShortcut() -> Bool {
        mode == .settings && settings.clearSelectedShortcut()
    }

    func goBack() -> Bool {
        switch mode {
        case .launcher:
            return false
        case .defineWord, .uninstallApp:
            mode = .launcher
            query = ""
        case .desktopSessions:
            desktopSessionList = nil
            mode = .launcher
            query = ""
        case .askClaude:
            guard chat == nil else {
                leaveChat()
                return true
            }
            isChatSaved = false
            showDesktopSessions()
        case .uninstallReview(let previousQuery):
            review = nil
            mode = .uninstallApp
            query = previousQuery
        case .wordEntry(_, let wordQuery):
            mode = .defineWord
            query = wordQuery
        case .quickLinkForm(_, let previousQuery):
            mode = .launcher
            query = previousQuery
        case .settings:
            settings.finishEditing()
            if !query.isEmpty {
                query = ""
                return true
            }
            if settings.goUp() { return true }
            mode = .launcher
            query = ""
        case .ruleForm(_, _, let previousQuery), .keySwapForm(let previousQuery), .aliasForm(let previousQuery), .shellTextForm(_, let previousQuery):
            settings.reload()
            mode = .settings
            query = previousQuery
        }
        return true
    }

    func editSelectedLink() -> Bool {
        guard case .quickLink(let link) = selectedResult else { return false }
        showForm(.edit, for: link, returningTo: query)
        return true
    }

    func duplicateSelectedLink() -> Bool {
        guard case .quickLink(let link) = selectedResult else { return false }
        showForm(.duplicate, for: link.duplicate, returningTo: query)
        return true
    }

    func saveDraft() {
        if case .ruleForm = mode { return saveRuleDraft() }
        if case .keySwapForm = mode { return saveKeySwapDraft() }
        if case .aliasForm = mode { return saveAliasDraft() }
        if case .shellTextForm(let text, _) = mode { return saveShellTextDraft(text) }
        guard draft.isComplete else { return NSSound.beep() }
        QuickLinkLibrary.shared.save(draft)
        _ = goBack()
    }

    func toggleActions() -> Bool {
        if actionPanel != nil {
            closeActions()
            return true
        }
        if mode == .settings, let setting = settings.selectedSetting, case .rule(let rule) = setting.row, !setting.isDisabled {
            showPanel(for: .rule(rule))
            return true
        }
        guard case .quickLink(let link) = selectedResult else { return false }
        showActions(for: link, page: .actions)
        return true
    }

    func toggleAnvilActions() {
        if case .anvil = actionPanel?.subject { return closeActions() }
        actionPanel = ActionPanel(subject: .anvil)
        field = .actionFilter
    }

    /// Pins or unpins the search bar. While pinned, nothing hides it: not clicking elsewhere, not Escape, and not opening what was searched for.
    func togglePin() {
        isPinned.toggle()
    }

    func pin() {
        isPinned = true
    }

    private func saveRuleDraft() {
        guard let rule = ruleDraft.rule else { return NSSound.beep() }
        RuleLibrary.shared.save(rule)
        _ = goBack()
    }

    private func saveKeySwapDraft() {
        guard let keySwap = keySwapDraft.keySwap else { return NSSound.beep() }
        KeySwapLibrary.shared.add(keySwap)
        _ = goBack()
    }

    private func saveAliasDraft() {
        guard aliasDraft.isComplete else { return NSSound.beep() }
        ShellLibrary.shared.save(aliasDraft)
        _ = goBack()
    }

    private func saveShellTextDraft(_ text: ShellText) {
        text.save(shellTextDraft)
        _ = goBack()
    }

    private func showPanel(for subject: ActionPanel.Subject) {
        actionPanel = ActionPanel(subject: subject)
        field = .actionFilter
    }

    func showActions(for link: QuickLink, page: ActionPanel.Page) {
        actionPanel = ActionPanel(subject: .quickLink(link), page: page)
        field = .actionFilter
    }

    func closeActions() {
        actionPanel = nil
        field = .query
    }

    func reloadResults() {
        launchCounts = SavedLaunchCounts.load()
        refresh()
    }

    func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    func open(_ link: QuickLink, filling values: [String], in app: URL?) {
        guard let target = link.target(filling: values) else { return }
        SavedLaunchCounts.record(link.launchKey)
        if let app {
            NSWorkspace.shared.open([target], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.open(target)
        }
    }

    private func refresh() {
        wordLookup?.cancel()
        selected = 0
        switch mode {
        case .launcher:
            results = LauncherSearch.results(for: query, in: AppCatalog.shared.apps, quickLinks: QuickLinkLibrary.shared.links, commands: availableCommands, launchCounts: launchCounts, rates: CurrencyRatesStore.shared.rates)
        case .uninstallApp:
            results = LauncherSearch.removableApps(matching: query, in: appsOtherThanAnvil)
        case .uninstallReview:
            results = []
            review?.select(0)
        case .defineWord:
            let candidates = isQueryEmpty ? SavedRecentWords.load().words : WordLookup.candidates(for: query)
            wordLookup = Task {
                let words = await Task.detached { WordLookup.words(from: candidates) }.value
                guard !Task.isCancelled else { return }
                results = words.map(SearchResult.word)
                showArguments()
            }
        case .settings:
            results = []
            settings.filter(query)
        case .wordEntry, .quickLinkForm, .ruleForm, .keySwapForm, .aliasForm, .shellTextForm, .askClaude:
            results = []
        case .desktopSessions:
            results = []
            desktopSessionList?.select(0)
        }
        showArguments()
    }

    private func showArguments() {
        let link: QuickLink? = if case .quickLink(let link) = selectedResult { link } else { nil }
        if arguments.show(for: link) { field = .query }
    }

    private func run(_ command: LauncherCommand) {
        SavedLaunchCounts.record(command.launchKey)
        switch command {
        case .defineWord:
            mode = .defineWord
        case .createQuickLink:
            showForm(.create, for: QuickLink(), returningTo: "")
        case .settings:
            settings.start()
            mode = .settings
        case .uninstallApp:
            mode = .uninstallApp
            let removableApps = appsOtherThanAnvil.filter(\.isRemovable).map(\.url)
            LeftoverIndexStore.shared.search(AppCatalog.shared.apps.map(\.url)) { AppSizes.shared.measure(removableApps, with: $0) }
        case .enterAIMode:
            showDesktopSessions()
        }
        query = ""
    }

    private func sendPrompt() {
        let prompt = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, canSend else { return NSSound.beep() }
        send(prompt)
        query = ""
    }

    private var canSend: Bool {
        chat?.isAnswering != true && claudeUpdate.state != .updating
    }

    private func send(_ prompt: String) {
        let chat = chat ?? ClaudeChatSession(folder: chatSetup.folder, update: claudeUpdate)
        self.chat = chat
        claudeUpdate.forget()
        chat.send(prompt, mode: chatSetup.mode)
    }

    /// Whether the search bar should come back as it was however long it was hidden, because a chat is going on or a sign-in is still waiting on the browser.
    var isHoldingChat: Bool {
        chat != nil || claudeSignIn.state == .signingIn
    }

    /// Signs Claude Code in, and once it is signed in, sends the prompt waiting in the field, if AI mode is still open and there is one.
    func signInToClaude() {
        claudeSignIn.signIn { [weak self] in
            guard let self, mode == .askClaude, !isQueryEmpty else { return }
            sendPrompt()
        }
    }

    /// Updates Claude Code, and once it is updated, sends again the prompt that found it too old.
    func updateClaude() {
        claudeUpdate.update { [weak self] in
            guard let self, let prompt = chat?.turns.last?.prompt, canSend else { return }
            send(prompt)
        }
    }

    func leaveChat() {
        guard !isChatSaved else { return saveChat() }
        chatQuestion = .leave
    }

    private func continueSelectedChat() {
        guard let session = desktopSessionList?.selectedSession(matching: query) else { return NSSound.beep() }
        let chat = carryOn(session)
        Task { await chat.loadHistory() }
    }

    private func carryOn(_ session: DesktopSession) -> ClaudeChatSession {
        let chat = ClaudeChatSession(resuming: session, update: claudeUpdate)
        self.chat = chat
        isChatSaved = true
        desktopSessionList = nil
        wantsExpanded = false
        mode = .askClaude
        query = ""
        claudeSignIn.check()
        return chat
    }

    /// Sends what was said by voice to the session it names, beeping if nothing is left once the session's name is dropped. Whether anything was sent, or is about to be.
    @discardableResult
    func sendSpoken(_ said: String) -> Bool {
        let spoken = SpokenPrompt(said)
        guard !spoken.text.isEmpty else {
            NSSound.beep()
            return false
        }
        switch spoken.session {
        case .new: sendToNewChat(spoken.text)
        case .last: sendToLastSession(spoken.text)
        }
        return true
    }

    /// Whether what was said by voice needs the search bar to go on: a question waits before leaving the chat, or the prompt waits in the field while Claude is busy.
    var needsBarAfterSpeaking: Bool {
        chat == nil || chatQuestion != nil || !isQueryEmpty
    }

    /// Opens the chat in Claude desktop and lets go of it once Claude has answered, so Claude desktop alone carries the session on from there, and the next prompt said by voice reads it afresh from its file.
    func handOverToClaudeDesktop() {
        guard let chat else { return }
        Task { await ClaudeDesktop.open(chat.sessionID) }
        Task {
            await Self.answered(chat)
            guard self.chat === chat, chatQuestion == nil else { return }
            saveChat()
        }
    }

    /// Waits until Claude has started answering and then finished, since a prompt sent after the chat's earlier turns are read has not started yet when this begins.
    private static func answered(_ chat: ClaudeChatSession) async {
        var hasStarted = false
        for await isAnswering in Observations({ chat.isAnswering }) {
            if isAnswering {
                hasStarted = true
            } else if hasStarted {
                return
            }
        }
    }

    /// A chat already going on in AI mode gets it, since leaving that chat for another could lose it. Otherwise it goes to the Claude desktop session used last, whose earlier turns are read first so they show above it, or to a new chat if there is no session at all.
    private func sendToLastSession(_ prompt: String) {
        guard chat == nil, let session = DesktopSessionFiles.lastUsed() else { return startNewChat(prompt) }
        let chat = carryOn(session)
        Task {
            await chat.loadHistory()
            sendOrHold(prompt)
        }
    }

    /// A chat going on in AI mode is left first. A saved one is left straight away, and an unsaved one asks the usual question, with the new chat starting once it is left, or the prompt moving into the field to send here if chatting goes on.
    private func sendToNewChat(_ prompt: String) {
        guard let chat else { return startNewChat(prompt) }
        guard isChatSaved else {
            promptAfterLeaving = prompt
            chatQuestion = .leave
            return
        }
        ClaudeDesktop.save(chat.sessionID)
        endChat()
        startNewChat(prompt)
    }

    private func startNewChat(_ prompt: String) {
        desktopSessionList = nil
        mode = .askClaude
        query = ""
        sendOrHold(prompt)
    }

    /// Sends the prompt, unless Claude is still answering or Claude Code is being updated, in which case it waits in the field.
    private func sendOrHold(_ prompt: String) {
        guard canSend else {
            query = prompt
            return
        }
        send(prompt)
    }

    /// Opens AI mode on the list of Claude desktop sessions, where typing narrows it and Tab starts a new chat. It only opens from the launcher, and only while the AI tool is on.
    func enterAIMode() -> Bool {
        guard mode == .launcher, Tool.ai.isOn else { return false }
        showDesktopSessions()
        return true
    }

    func startChat() {
        desktopSessionList = nil
        wantsExpanded = false
        mode = .askClaude
        query = ""
        claudeSignIn.check()
    }

    private func showDesktopSessions() {
        desktopSessionList = DesktopSessionList()
        mode = .desktopSessions
        query = ""
    }

    func setExpanded(_ expanded: Bool) {
        wantsExpanded = expanded
    }

    /// Saves the chat into Claude desktop, so leaving it no longer asks. Before the first prompt there is nothing for Claude desktop to take yet, so it is saved when the chat is left.
    func startSavingChat() {
        isChatSaved = true
        if let chat { ClaudeDesktop.save(chat.sessionID) }
    }

    func keepChatting() {
        chatQuestion = nil
        if let promptAfterLeaving { query = promptAfterLeaving }
        promptAfterLeaving = nil
    }

    /// The buttons of the question card at the end of the chat, left to right, or none when no card is asking.
    var cardChoices: [CardChoice] {
        switch chatState {
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
        case .saveAndLeave: saveChat()
        case .leave: discardChat()
        case .deny: chat?.answerApproval(allowed: false)
        case .allow: chat?.answerApproval(allowed: true)
        }
    }

    func saveChat() {
        guard let chat else { return }
        let waiting = promptAfterLeaving
        ClaudeDesktop.save(chat.sessionID)
        endChat()
        showDesktopSessions()
        if let waiting { startNewChat(waiting) }
    }

    func discardChat() {
        guard let chat else { return }
        let waiting = promptAfterLeaving
        self.chat = nil
        chatQuestion = nil
        promptAfterLeaving = nil
        isChatSaved = false
        Task { await chat.discard() }
        showDesktopSessions()
        if let waiting { startNewChat(waiting) }
    }

    private func endChat() {
        chat?.end()
        chat = nil
        chatQuestion = nil
        promptAfterLeaving = nil
        isChatSaved = false
    }

    private var appsOtherThanAnvil: [InstalledApp] {
        AppCatalog.shared.apps.filter { $0.url != Bundle.main.bundleURL }
    }

    func moveTickedToTrash() -> Bool {
        guard case .uninstallReview = mode, let review else { return false }
        Task {
            guard await review.moveTickedToTrash() else { return }
            SystemSounds.playMoveToTrash()
            AppCatalog.shared.reload()
            guard self.review === review else { return }
            _ = goBack()
            query = ""
        }
        return true
    }

    func revealSelected() -> Bool {
        guard case .uninstallReview = mode, let review, let item = review.selectedItem(matching: query) else { return false }
        review.reveal(item)
        return true
    }

    private func showReview(of app: InstalledApp) {
        guard let index = LeftoverIndexStore.shared.index else { return NSSound.beep() }
        let review = UninstallReview(app: app)
        self.review = review
        mode = .uninstallReview(query: query)
        query = ""
        let otherAppURLs = AppCatalog.shared.apps.map(\.url).filter { $0 != app.url }
        Task { await review.load(otherAppURLs: otherAppURLs, index: index) }
    }

    private var availableCommands: [LauncherCommand] {
        LauncherCommand.allCases.filter { command in
            switch command {
            case .uninstallApp: Tool.uninstaller.isOn
            case .enterAIMode: Tool.ai.isOn
            default: true
            }
        }
    }

    private func showForm(_ kind: QuickLinkFormKind, for link: QuickLink, returningTo previousQuery: String) {
        draft = link
        quickLinkField = .name
        mode = .quickLinkForm(kind, query: previousQuery)
        query = ""
    }

    private func launch(_ app: InstalledApp) {
        SavedLaunchCounts.record(app.url.path)
        NSWorkspace.shared.openApplication(at: app.url, configuration: NSWorkspace.OpenConfiguration())
    }
}
