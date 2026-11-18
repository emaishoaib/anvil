import ClaudeKit
import Foundation
import Observation

/// The Load Chat page: Claude desktop's Code sessions, newest first, narrowed by the search field to those whose title or folder contains it, and the one selected.
@Observable final class DesktopSessionList {
    private(set) var sessions = DesktopSessionFiles.newestFirst()
    private(set) var selected = 0

    func sessions(matching query: String) -> [DesktopSession] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return sessions }
        return sessions.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.folder.path.localizedCaseInsensitiveContains(query) }
    }

    func selectedSession(matching query: String) -> DesktopSession? {
        let matching = sessions(matching: query)
        return matching.indices.contains(selected) ? matching[selected] : nil
    }

    func select(_ index: Int) {
        selected = index
    }

    func moveSelection(by offset: Int, matching query: String) {
        let count = sessions(matching: query).count
        guard count > 0 else { return }
        selected = min(max(selected + offset, 0), count - 1)
    }
}
