import AppKit
import ClaudeKit
import LauncherKit
import Observation

@Observable final class SearchModel {
    private(set) var mode = SearchMode.launcher
    var query = "" {
        didSet { refresh() }
    }
    private(set) var results: [SearchResult] = []
    private(set) var currencyTable: CurrencyTable?
    private(set) var selected = 0
    private(set) var entryPage = ""
    var field = SearchField.query
    var arguments = LinkArguments()
    var draft = QuickLink()
    var quickLinkField = QuickLinkField.name
    var ruleDraft = RuleDraft()
    var keySwapDraft = KeySwapDraft()
    var phraseDraft = ""
    private(set) var actionPanel: ActionPanel?
    private(set) var review: UninstallReview?
    private(set) var desktopSessionList: DesktopSessionList?
    private(set) var screenshot: ScreenshotPage?
    private(set) var currencyPicker: CurrencyPicker?
    private var screenshotToSend: Data?
    private(set) var timesOpened = 0
    private(set) var isPinned = false
    let settings = SettingsBarModel()
    let chatSetup = ChatSetup()
    private(set) var chatModel: ChatModel?
    private var wantsExpanded = false

    var isExpanded: Bool {
        mode == .askClaude && wantsExpanded
    }
    let claudeSignIn = ClaudeSignIn()
    let claudeUpdate = ClaudeUpdate()
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

    /// The field's hint for the current mode, the chat's own hint in AI mode, or a hint about the screenshot while picking a chat to send it to.
    var placeholder: String {
        if mode == .desktopSessions, screenshotToSend != nil { return "Choose a chat for the screenshot, or press Tab for a new chat…" }
        guard mode == .askClaude, let chatModel else { return mode.placeholder }
        return chatModel.placeholder
    }

    var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Whether the field is empty, which in AI mode means the chat's prompt.
    var isFieldEmpty: Bool {
        guard mode == .askClaude, let chatModel else { return query.isEmpty }
        return chatModel.prompt.isEmpty
    }

    func reset() {
        settings.finishEditing()
        chatModel?.end()
        chatModel = nil
        wantsExpanded = false
        LeftoverIndexStore.shared.forget()
        launchCounts = SavedLaunchCounts.load()
        actionPanel = nil
        review = nil
        desktopSessionList = nil
        screenshot = nil
        screenshotToSend = nil
        currencyPicker = nil
        arguments = LinkArguments()
        draft = QuickLink()
        ruleDraft = RuleDraft()
        keySwapDraft = KeySwapDraft()
        phraseDraft = ""
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
        if mode == .screenshot {
            screenshot?.moveSelection(by: offset, matching: query)
            return
        }
        if case .currencyPicker = mode {
            currencyPicker?.moveSelection(by: offset, matching: query)
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

    func moveQuickLinkFocus(by offset: Int) -> Bool {
        guard case .quickLinkForm = mode else { return false }
        quickLinkField = quickLinkField.moved(by: offset)
        return true
    }

    func leaveArguments() -> Bool {
        guard field != .query else { return false }
        field = .query
        return true
    }

    func openSelected() {
        if mode == .askClaude { return chatModel?.sendPrompt() ?? () }
        if mode == .desktopSessions { return continueSelectedChat() }
        if mode == .screenshot { return runSelectedScreenshotAction() }
        if case .currencyPicker = mode { return currencyPicker?.addSelected(matching: query) == true ? () : NSSound.beep() }
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

    /// Opens the currency picker over the launcher or the settings, whichever is showing, and going back returns there with the text as it was.
    func showCurrencyPicker() {
        settings.finishEditing()
        actionPanel = nil
        currencyPicker = CurrencyPicker()
        mode = .currencyPicker(fromSettings: mode == .settings, query: query)
        query = ""
    }

    /// Removes the selected currency on the currency picker, or beeps when it isn't one of the chosen ones. Whether the picker is showing.
    func removeSelectedCurrency() -> Bool {
        guard case .currencyPicker = mode else { return false }
        if currencyPicker?.removeSelected(matching: query) != true { NSSound.beep() }
        return true
    }

    /// Moves the selected currency up or down the currency picker's chosen list, or beeps when it can't go further. Whether the picker is showing.
    func moveSelectedCurrency(by offset: Int) -> Bool {
        guard case .currencyPicker = mode else { return false }
        if currencyPicker?.moveSelected(by: offset, matching: query) != true { NSSound.beep() }
        return true
    }

    func showKeySwapForm() {
        settings.finishEditing()
        keySwapDraft = KeySwapDraft()
        mode = .keySwapForm(query: query)
        query = ""
    }

    func showPhraseForm(_ phrase: SpokenPhrase) {
        settings.finishEditing()
        phraseDraft = phrase.current
        mode = .phraseForm(phrase, query: query)
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
            if let png = screenshotToSend {
                screenshotToSend = nil
                showScreenshot(png)
                return true
            }
            mode = .launcher
            query = ""
        case .screenshot:
            closeScreenshot()
        case .askClaude:
            if let chatModel, chatModel.isStarted {
                chatModel.leave()
                return true
            }
            chatModel = nil
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
        case .ruleForm(_, _, let previousQuery), .keySwapForm(let previousQuery), .phraseForm(_, let previousQuery):
            settings.reload()
            mode = .settings
            query = previousQuery
        case .currencyPicker(let fromSettings, let previousQuery):
            currencyPicker = nil
            if fromSettings { settings.reload() }
            mode = fromSettings ? .settings : .launcher
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
        if case .phraseForm(let phrase, _) = mode { return savePhraseDraft(phrase) }
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

    /// Lets go of the chat in AI mode without ending it, so it can carry on in a window of its own, and goes back to the launcher, unpinned.
    func releaseChat() -> ChatModel? {
        guard mode == .askClaude, let chat = chatModel else { return nil }
        chat.onLeave = { _ in }
        chatModel = nil
        isPinned = false
        wantsExpanded = false
        mode = .launcher
        query = ""
        return chat
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

    private func savePhraseDraft(_ phrase: SpokenPhrase) {
        guard phrase.save(phraseDraft) else { return NSSound.beep() }
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
        currencyTable = nil
        switch mode {
        case .launcher:
            results = LauncherSearch.results(for: query, in: AppCatalog.shared.apps, quickLinks: QuickLinkLibrary.shared.links, commands: availableCommands, launchCounts: launchCounts, rates: CurrencyRatesStore.shared.rates)
            currencyTable = CurrencyTable(for: query, codes: ChosenCurrencies.codes, rates: CurrencyRatesStore.shared.rates)
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
        case .wordEntry, .quickLinkForm, .ruleForm, .keySwapForm, .phraseForm, .askClaude:
            results = []
        case .desktopSessions:
            results = []
            desktopSessionList?.select(0)
        case .screenshot:
            results = []
            screenshot?.select(0)
        case .currencyPicker:
            results = []
            currencyPicker?.select(0)
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

    /// Whether the search bar should come back as it was however long it was hidden, because a chat is going on or a sign-in is still waiting on the browser.
    var isHoldingChat: Bool {
        chatModel?.isStarted == true || claudeSignIn.state == .signingIn
    }

    /// Shows a screenshot just taken on a page of its own, which goes back to the chat in AI mode afterwards when one was going on there.
    func showScreenshot(_ png: Data) {
        settings.finishEditing()
        actionPanel = nil
        screenshot = ScreenshotPage(png: png)
        mode = .screenshot
        query = ""
    }

    private func runSelectedScreenshotAction() {
        guard let screenshot, let action = screenshot.selectedAction(matching: query) else { return NSSound.beep() }
        switch action {
        case .saveToDesktop:
            guard DesktopScreenshot.save(screenshot.png) else { return NSSound.beep() }
            closeScreenshot()
            SearchBar.shared.hide()
        case .sendToClaudeCode:
            screenshotToSend = screenshot.png
            self.screenshot = nil
            guard let chatModel else { return showDesktopSessions() }
            giveScreenshot(to: chatModel)
            mode = .askClaude
            query = ""
        }
    }

    /// Hands the screenshot waiting for a chat to the given one, where it goes with the next prompt sent.
    private func giveScreenshot(to chat: ChatModel) {
        guard let png = screenshotToSend else { return }
        screenshotToSend = nil
        chat.attach(png)
    }

    private func closeScreenshot() {
        screenshot = nil
        mode = chatModel == nil ? .launcher : .askClaude
        query = ""
    }

    /// Carries on the selected chat in AI mode, or brings its window forward when it is already showing in one, with any screenshot waiting for a chat attached to it. Its earlier turns show once the bar has finished sliding into AI mode.
    private func continueSelectedChat() {
        guard let session = desktopSessionList?.selectedSession(matching: query) else { return NSSound.beep() }
        if let window = ChatWindows.shared.window(running: session.sessionID) {
            giveScreenshot(to: window.chat)
            return SearchBar.shared.bringForward(window)
        }
        let chat = carryOn(session)
        giveScreenshot(to: chat)
        let swap = PanelAnimation.isReduced ? Duration.zero : .seconds(SearchBarView.swapSeconds)
        Task { await chat.loadHistory(showingAfter: swap) }
    }

    private func carryOn(_ session: DesktopSession) -> ChatModel {
        let chat = hold(ChatModel(resuming: session, setup: chatSetup, signIn: claudeSignIn, update: claudeUpdate))
        desktopSessionList = nil
        wantsExpanded = false
        mode = .askClaude
        query = ""
        claudeSignIn.check()
        return chat
    }

    @discardableResult
    private func newChat() -> ChatModel {
        hold(ChatModel(setup: chatSetup, signIn: claudeSignIn, update: claudeUpdate))
    }

    /// Makes the chat the one AI mode shows, and goes back to the chat list once it is left, starting a new chat with any prompt that was waiting for it to be left.
    private func hold(_ chat: ChatModel) -> ChatModel {
        chat.onLeave = { [weak self, weak chat] waiting in
            guard let self, let chat, chatModel === chat else { return }
            chatModel = nil
            showDesktopSessions()
            if let waiting { startNewChat(waiting) }
        }
        chatModel = chat
        return chat
    }

    /// Where a prompt said by voice went: nowhere, to the chat in the bar, or to a chat already showing in a window of its own.
    enum SentTo {
        case nowhere
        case bar
        case chatWindow(ChatWindow)
    }

    /// Sends what was said by voice to the session it names, beeping if nothing is left once the session's name is dropped.
    func sendSpoken(_ said: String) -> SentTo {
        let spoken = SpokenPhrase.prompt(in: said)
        guard !spoken.text.isEmpty else {
            NSSound.beep()
            return .nowhere
        }
        switch spoken.session {
        case .new:
            sendToNewChat(spoken.text)
            return .bar
        case .last:
            return sendToLastSession(spoken.text)
        }
    }

    /// Whether what was said by voice needs the search bar to go on: a question waits before leaving the chat, or the prompt waits in the field while Claude is busy.
    var needsBarAfterSpeaking: Bool {
        guard let chatModel, chatModel.isStarted else { return true }
        return chatModel.question != nil || !chatModel.isPromptEmpty
    }

    /// Opens the chat in Claude desktop and lets go of it once Claude has answered, so Claude desktop alone carries the session on from there, and the next prompt said by voice reads it afresh from its file.
    func handOverToClaudeDesktop() {
        guard let chat = chatModel, let session = chat.session else { return }
        Task { await ClaudeDesktop.open(session.sessionID) }
        Task {
            await Self.answered(session)
            guard chatModel === chat, chat.question == nil else { return }
            chat.save()
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

    /// A chat already going on in AI mode gets it, since leaving that chat for another could lose it. Otherwise it goes to the Claude desktop session used last, in the window already showing it if there is one, or else here with its earlier turns read first so they show above it, or to a new chat if there is no session at all.
    private func sendToLastSession(_ prompt: String) -> SentTo {
        if let chatModel, chatModel.isStarted {
            chatModel.sendOrHold(prompt)
            return .bar
        }
        guard let session = DesktopSessionFiles.lastUsed() else {
            startNewChat(prompt)
            return .bar
        }
        if let window = ChatWindows.shared.window(running: session.sessionID) {
            window.chat.sendOrHold(prompt)
            return .chatWindow(window)
        }
        let chat = carryOn(session)
        Task {
            await chat.loadHistory()
            chat.sendOrHold(prompt)
        }
        return .bar
    }

    /// A chat going on in AI mode is left first. A saved one is left straight away, and an unsaved one asks the usual question, with the new chat starting once it is left, or the prompt moving into the field to send here if chatting goes on.
    private func sendToNewChat(_ prompt: String) {
        guard let chatModel, chatModel.isStarted else { return startNewChat(prompt) }
        chatModel.leave(thenSending: prompt)
    }

    private func startNewChat(_ prompt: String) {
        let chat = newChat()
        desktopSessionList = nil
        mode = .askClaude
        query = ""
        chat.sendOrHold(prompt)
    }

    /// Opens AI mode on the list of Claude desktop sessions, where typing narrows it and Tab starts a new chat. It only opens from the launcher, and only while the AI tool is on.
    func enterAIMode() -> Bool {
        guard mode == .launcher, Tool.ai.isOn else { return false }
        showDesktopSessions()
        return true
    }

    /// Starts a new chat in AI mode, with any screenshot waiting for a chat attached to it.
    func startChat() {
        giveScreenshot(to: newChat())
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
