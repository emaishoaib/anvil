import AppKit
import CleanerKit
import LauncherKit
import Observation

/// The uninstall page for one app: the app and the files it left behind, each ticked to go to the Trash until it is unticked. An item that may hold the user's own files starts unticked instead. The files named after the app elsewhere on the Mac come from the walk done when the uninstall list opened. The items are found and measured away from the main thread, because a large app takes a while to measure. The query narrows the rows by name, and the selection moves through the rows that are shown.
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
    private(set) var failureReasons: [URL: String] = [:]
    private(set) var hasFullDiskAccess = true
    private(set) var needsAppManagement = false

    init(app: InstalledApp) {
        self.app = app
    }

    func load(otherAppURLs: [URL], index: LeftoverIndex) async {
        let appURL = app.url
        let foundByName = index.finds(forAppAt: appURL)
        let (items, hasFullDiskAccess) = await Task.detached {
            (RemovalPlan.items(forAppAt: appURL, in: .current, otherAppURLs: otherAppURLs, foundByName: foundByName), FullDiskAccess.isGranted)
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
        let errors = await Self.moveToTrash(ticked)
        failureReasons = errors.mapValues(\.localizedDescription)
        needsAppManagement = ticked.contains { $0.kind == .app && Self.isPermissionDenied(errors[$0.url]) }
        state = .ready(items.filter { !isTicked($0) || failureReasons[$0.url] != nil })
        selected = 0
        guard failureReasons.isEmpty else {
            problem = "Couldn't move \(failureReasons.count) of \(ticked.count) items to the Trash"
            return false
        }
        return true
    }

    /// Moves each item to the Trash, and gives the error for each one that could not be moved. Items owned by root go through Finder together, so the admin password is asked for once.
    private static func moveToTrash(_ items: [RemovalItem]) async -> [URL: any Error] {
        var errors: [URL: any Error] = [:]
        for item in items where !isOwnedByRoot(item.url) {
            do {
                try FileManager.default.trashItem(at: item.url, resultingItemURL: nil)
            } catch {
                errors[item.url] = error
            }
        }
        let ownedByRoot = items.filter { isOwnedByRoot($0.url) }
        guard !ownedByRoot.isEmpty else { return errors }
        do {
            try await FinderTrash.moveToTrash(ownedByRoot.map(\.url))
        } catch {
            for item in ownedByRoot where FileManager.default.fileExists(atPath: item.url.path(percentEncoded: false)) {
                errors[item.url] = error
            }
        }
        return errors
    }

    private static func isOwnedByRoot(_ url: URL) -> Bool {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
        return attributes?[.ownerAccountID] as? Int == 0
    }

    private static func isPermissionDenied(_ error: (any Error)?) -> Bool {
        (error as? CocoaError)?.code == .fileWriteNoPermission
    }

    func selectedItem(matching query: String) -> RemovalItem? {
        let items = items(matching: query)
        return items.indices.contains(selected) ? items[selected] : nil
    }

    func toggleSelected(matching query: String) {
        guard let item = selectedItem(matching: query) else { return }
        toggle(item)
    }

    /// Opens Finder with the item selected inside its folder.
    func reveal(_ item: RemovalItem) {
        NSWorkspace.shared.activateFileViewerSelecting([item.url])
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
