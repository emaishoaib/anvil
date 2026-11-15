import AppKit
import CleanerKit
import LauncherKit
import Observation

/// The uninstall page for one app: the app and the files it left behind, each ticked to go to the Trash until it is unticked. An item that may hold the user's own files starts unticked instead. The items are found and measured away from the main thread, because a large app takes a while to measure. The query narrows the rows by name, and the selection moves through the rows that are shown.
@Observable final class UninstallReview {
    enum State {
        case searching
        case ready([RemovalItem])
        case movingToTrash
    }

    let app: InstalledApp
    private(set) var state = State.searching
    private(set) var unticked: Set<URL> = []
    private(set) var selected = 0
    private(set) var problem: String?
    private(set) var hasFullDiskAccess = true

    init(app: InstalledApp) {
        self.app = app
    }

    func load(otherAppURLs: [URL]) async {
        let appURL = app.url
        let (items, hasFullDiskAccess) = await Task.detached {
            (RemovalPlan.items(forAppAt: appURL, in: .current, otherAppURLs: otherAppURLs), FullDiskAccess.isGranted)
        }.value
        self.hasFullDiskAccess = hasFullDiskAccess
        unticked = Set(items.filter { !$0.startsTicked }.map(\.url))
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
        problem = nil
        unticked.formSymmetricDifference([item.url])
    }

    /// Quits the app, then moves every ticked item to the Trash. Gives true when everything ticked has gone. Otherwise the page lists what is still on disk, and says what went wrong.
    func moveTickedToTrash() async -> Bool {
        guard case .ready(let items) = state else { return false }
        let ticked = items.filter(isTicked)
        guard !ticked.isEmpty else {
            NSSound.beep()
            return false
        }
        state = .movingToTrash
        guard await AppQuitting.quit(appAt: app.url) else {
            state = .ready(items)
            problem = "\(app.name) didn't quit. Quit it, then try again"
            return false
        }
        let failed = ticked.filter { (try? FileManager.default.trashItem(at: $0.url, resultingItemURL: nil)) == nil }
        let moved = Set(ticked).subtracting(failed)
        state = .ready(items.filter { !moved.contains($0) })
        selected = 0
        guard failed.isEmpty else {
            problem = "Couldn't move \(failed.count) of \(ticked.count) items to the Trash"
            return false
        }
        return true
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
        if let problem { return problem }
        switch state {
        case .searching:
            return "Looking for leftovers…"
        case .movingToTrash:
            return "Moving to the Trash…"
        case .ready(let items):
            let ticked = items.filter(isTicked)
            let size = ticked.reduce(0) { $0 + $1.sizeBytes }.formatted(.byteCount(style: .file))
            return "\(ticked.count) of \(items.count) ticked, \(size)"
        }
    }
}
