import AppKit
import LauncherKit
import Observation

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
    var ruleDraft = RuleDraft()
    var keySwapDraft = KeySwapDraft()
    private(set) var actionPanel: ActionPanel?
    private(set) var review: UninstallReview?
    private(set) var timesOpened = 0
    private(set) var isPinned = false
    let settings = SettingsBarModel()
    let chatSetup = ChatSetup()
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

    var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func reset() {
        settings.finishEditing()
        LeftoverIndexStore.shared.forget()
        launchCounts = SavedLaunchCounts.load()
        actionPanel = nil
        review = nil
        arguments = LinkArguments()
        draft = QuickLink()
        ruleDraft = RuleDraft()
        keySwapDraft = KeySwapDraft()
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
        guard !results.isEmpty else { return }
        selected = min(max(selected + offset, 0), results.count - 1)
        showArguments()
    }

    func moveFocus(by offset: Int) -> Bool {
        guard mode == .launcher, !arguments.placeholders.isEmpty else { return false }
        field = field.moved(by: offset, argumentCount: arguments.placeholders.count)
        return true
    }

    func leaveArguments() -> Bool {
        guard field != .query else { return false }
        field = .query
        return true
    }

    func openSelected() {
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
            SearchBar.shared.hide()
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
            SearchBar.shared.hide()
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

    func clearSelectedShortcut() -> Bool {
        mode == .settings && settings.clearSelectedShortcut()
    }

    func goBack() -> Bool {
        switch mode {
        case .launcher:
            return false
        case .defineWord, .uninstallApp, .askClaude:
            mode = .launcher
            query = ""
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
        case .ruleForm(_, _, let previousQuery), .keySwapForm(let previousQuery):
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
        case .wordEntry, .quickLinkForm, .ruleForm, .keySwapForm, .askClaude:
            results = []
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
        case .askClaude:
            mode = .askClaude
        }
        query = ""
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
            case .askClaude: Tool.ai.isOn
            default: true
            }
        }
    }

    private func showForm(_ kind: QuickLinkFormKind, for link: QuickLink, returningTo previousQuery: String) {
        draft = link
        mode = .quickLinkForm(kind, query: previousQuery)
        query = ""
    }

    private func launch(_ app: InstalledApp) {
        SavedLaunchCounts.record(app.url.path)
        NSWorkspace.shared.openApplication(at: app.url, configuration: NSWorkspace.OpenConfiguration())
    }
}
