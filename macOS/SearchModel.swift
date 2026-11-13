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
    @ObservationIgnored private var wordLookup: Task<Void, Never>?

    var selectedResult: SearchResult? {
        results.indices.contains(selected) ? results[selected] : nil
    }

    func moveSelection(by offset: Int) {
        guard !results.isEmpty else { return }
        selected = min(max(selected + offset, 0), results.count - 1)
    }

    func openSelected() {
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
        case .word(let word):
            WordLookup.openInDictionary(word)
            SearchBar.shared.hide()
        }
    }

    func goBack() -> Bool {
        guard mode != .launcher else { return false }
        mode = .launcher
        query = ""
        return true
    }

    private func refresh() {
        wordLookup?.cancel()
        selected = 0
        switch mode {
        case .launcher:
            results = LauncherSearch.results(for: query, in: AppCatalog.shared.apps, launchCounts: SavedLaunchCounts.load(), rates: CurrencyRatesStore.shared.rates)
        case .defineWord:
            let candidates = WordLookup.candidates(for: query)
            wordLookup = Task {
                let words = await Task.detached { WordLookup.words(from: candidates) }.value
                guard !Task.isCancelled else { return }
                results = words.map(SearchResult.word)
            }
        }
    }

    private func run(_ command: LauncherCommand) {
        SavedLaunchCounts.record(command.launchKey)
        switch command {
        case .defineWord: mode = .defineWord
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
}
