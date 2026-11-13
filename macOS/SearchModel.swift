import AppKit
import LauncherKit
import Observation

@Observable final class SearchModel {
    var query = "" {
        didSet {
            results = LauncherSearch.results(for: query, in: AppCatalog.shared.apps, launchCounts: SavedLaunchCounts.load())
            selected = 0
        }
    }
    private(set) var results: [SearchResult] = []
    private(set) var selected = 0

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
        case .answer(let answer): copy(answer.copyText)
        case .app(let app): launch(app)
        }
        SearchBar.shared.hide()
    }

    private func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func launch(_ app: InstalledApp) {
        SavedLaunchCounts.record(app)
        NSWorkspace.shared.openApplication(at: app.url, configuration: NSWorkspace.OpenConfiguration())
    }
}
