import CleanerKit
import Foundation
import Observation

/// The leftovers of every installed app, found in one walk of the Mac when the uninstall list opens. The walk takes a while, so an app can only be picked once it is done, and the work waiting on it, such as measuring app sizes, runs only then. Opening the list again walks the Mac again, so files made since are found, unless a walk is already going.
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

    func search(_ appURLs: [URL], whenReady: @escaping (LeftoverIndex) -> Void) {
        guard !isSearching else { return }
        state = .searching
        Task {
            let index = await Task.detached { LeftoverIndex(appURLs: appURLs) }.value
            state = .ready(index)
            whenReady(index)
        }
    }
}
