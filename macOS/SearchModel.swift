import AppKit
import Observation

@Observable final class SearchModel {
    var query = "" {
        didSet {
            results = AppCatalog.shared.matches(query)
            selected = 0
        }
    }
    private(set) var results: [InstalledApp] = []
    private(set) var selected = 0

    func moveSelection(by offset: Int) {
        guard !results.isEmpty else { return }
        selected = min(max(selected + offset, 0), results.count - 1)
    }

    func openSelected() {
        guard results.indices.contains(selected) else { return }
        open(results[selected])
    }

    func open(_ app: InstalledApp) {
        LaunchCounts.record(app)
        NSWorkspace.shared.openApplication(at: app.url, configuration: NSWorkspace.OpenConfiguration())
        SearchBar.shared.hide()
    }
}
