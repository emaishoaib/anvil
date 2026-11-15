import CleanerKit
import Foundation
import Observation

/// The leftovers of every installed app, found in one walk of the Mac when the uninstall list opens. The walk takes a while, so an app can only be picked once it is done, and the work waiting on it, such as measuring app sizes, runs only then. The walk is kept while the search bar stays open, so opening the list again reuses it. Once the search bar opens afresh, the next list walks the Mac again, so files made since are found.
@Observable final class LeftoverIndexStore {
    static let shared = LeftoverIndexStore()

    enum State {
        case idle
        case searching
        case ready(LeftoverIndex)
    }

    private(set) var state = State.idle

    var index: LeftoverIndex? {
        guard case .ready(let index) = state else { return nil }
        return index
    }

    var isSearching: Bool {
        guard case .searching = state else { return false }
        return true
    }

    /// Walks the Mac, unless a walk is already going or a finished one is kept.
    func search(_ appURLs: [URL], whenReady: @escaping (LeftoverIndex) -> Void) {
        guard case .idle = state else { return }
        state = .searching
        Task {
            let index = await Task.detached { LeftoverIndex(appURLs: appURLs) }.value
            state = .ready(index)
            whenReady(index)
        }
    }

    /// Drops a finished walk, so the next list walks the Mac again. A walk that is still going is left to finish.
    func forget() {
        guard case .ready = state else { return }
        state = .idle
    }
}
