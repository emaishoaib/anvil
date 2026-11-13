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
    private(set) var actionPanel: ActionPanel?
    @ObservationIgnored private var wordLookup: Task<Void, Never>?
    @ObservationIgnored private var launchCounts = SavedLaunchCounts.load()

    var selectedResult: SearchResult? {
        results.indices.contains(selected) ? results[selected] : nil
    }

    var resultsTitle: String {
        switch (mode, isQueryEmpty) {
        case (.defineWord, true): "Recent Words"
        case (.launcher, true): "Suggestions"
        default: "Results"
        }
    }

    private var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func reset() {
        launchCounts = SavedLaunchCounts.load()
        actionPanel = nil
        arguments = LinkArguments()
        draft = QuickLink()
        entryPage = ""
        field = .query
        mode = .launcher
        query = ""
    }

    func moveSelection(by offset: Int) {
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
        if case .wordEntry(let word, _) = mode {
            WordLookup.openInDictionary(word)
            return SearchBar.shared.hide()
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

    func goBack() -> Bool {
        switch mode {
        case .launcher:
            return false
        case .defineWord:
            mode = .launcher
            query = ""
        case .wordEntry(_, let wordQuery):
            mode = .defineWord
            query = wordQuery
        case .quickLinkForm(_, let previousQuery):
            mode = .launcher
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
        guard draft.isComplete else { return NSSound.beep() }
        QuickLinkLibrary.shared.save(draft)
        _ = goBack()
    }

    func toggleActions() -> Bool {
        if actionPanel != nil {
            closeActions()
            return true
        }
        guard case .quickLink(let link) = selectedResult else { return false }
        showActions(for: link, page: .actions)
        return true
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
            results = LauncherSearch.results(for: query, in: AppCatalog.shared.apps, quickLinks: QuickLinkLibrary.shared.links, launchCounts: launchCounts, rates: CurrencyRatesStore.shared.rates)
        case .defineWord:
            let candidates = isQueryEmpty ? SavedRecentWords.load().words : WordLookup.candidates(for: query)
            wordLookup = Task {
                let words = await Task.detached { WordLookup.words(from: candidates) }.value
                guard !Task.isCancelled else { return }
                results = words.map(SearchResult.word)
                showArguments()
            }
        case .wordEntry, .quickLinkForm:
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
        }
        query = ""
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
