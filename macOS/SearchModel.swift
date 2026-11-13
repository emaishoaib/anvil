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
    @ObservationIgnored private var wordLookup: Task<Void, Never>?

    var selectedResult: SearchResult? {
        results.indices.contains(selected) ? results[selected] : nil
    }

    var resultsTitle: String {
        mode == .defineWord && isQueryEmpty ? "Recent Words" : "Results"
    }

    private var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty
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
            open(link, filling: arguments.values)
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
        case .quickLinkForm(let previousQuery):
            mode = .launcher
            query = previousQuery
        }
        return true
    }

    func saveDraft() {
        guard draft.isComplete else { return NSSound.beep() }
        QuickLinkLibrary.shared.save(draft)
        _ = goBack()
    }

    private func refresh() {
        wordLookup?.cancel()
        selected = 0
        switch mode {
        case .launcher:
            results = LauncherSearch.results(for: query, in: AppCatalog.shared.apps, quickLinks: QuickLinkLibrary.shared.links, launchCounts: SavedLaunchCounts.load(), rates: CurrencyRatesStore.shared.rates)
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
            draft = QuickLink()
            mode = .quickLinkForm(query: "")
        }
        query = ""
    }

    private func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func launch(_ app: InstalledApp) {
        SavedLaunchCounts.record(app.url.path)
        NSWorkspace.shared.openApplication(at: app.url, configuration: NSWorkspace.OpenConfiguration())
    }

    private func open(_ link: QuickLink, filling values: [String]) {
        guard let target = link.target(filling: values) else { return }
        SavedLaunchCounts.record(link.launchKey)
        if let app = link.openWith {
            NSWorkspace.shared.open([target], withApplicationAt: app, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.open(target)
        }
    }
}
