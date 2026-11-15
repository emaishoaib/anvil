import CleanerKit
import Foundation
import LauncherKit
import Observation

/// The uninstall page for one app: the app and the files it left in the Library, each ticked to go to the Trash until it is unticked. The items are found and measured away from the main thread, because a large app takes a while to measure. The query narrows the rows by name, and the selection moves through the rows that are shown.
@Observable final class UninstallReview {
    enum State {
        case searching
        case ready([RemovalItem])
    }

    let app: InstalledApp
    private(set) var state = State.searching
    private(set) var unticked: Set<URL> = []
    private(set) var selected = 0

    init(app: InstalledApp) {
        self.app = app
    }

    func load(otherAppURLs: [URL]) async {
        let appURL = app.url
        let items = await Task.detached {
            RemovalPlan.items(forAppAt: appURL, inLibrary: .libraryDirectory, otherAppURLs: otherAppURLs)
        }.value
        state = .ready(items)
    }

    func items(matching query: String) -> [RemovalItem] {
        guard case .ready(let items) = state else { return [] }
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func isTicked(_ item: RemovalItem) -> Bool {
        !unticked.contains(item.url)
    }

    func toggle(_ item: RemovalItem) {
        unticked.formSymmetricDifference([item.url])
    }

    func toggleSelected(matching query: String) {
        let items = items(matching: query)
        guard items.indices.contains(selected) else { return }
        toggle(items[selected])
    }

    func moveSelection(by offset: Int, matching query: String) {
        let count = items(matching: query).count
        guard count > 0 else { return }
        selected = min(max(selected + offset, 0), count - 1)
    }

    func select(_ index: Int) {
        selected = index
    }

    var summary: String {
        guard case .ready(let items) = state else { return "Looking for leftovers…" }
        let ticked = items.filter(isTicked)
        let size = ticked.reduce(0) { $0 + $1.sizeBytes }.formatted(.byteCount(style: .file))
        return "\(ticked.count) of \(items.count) ticked, \(size)"
    }
}
