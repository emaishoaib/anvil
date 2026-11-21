import Foundation
import Observation

/// What can be done with a screenshot just taken. Sending it to Claude Code is only offered while the AI tool is on.
enum ScreenshotAction: CaseIterable {
    case saveToDesktop
    case sendToClaudeCode

    static var available: [ScreenshotAction] {
        Tool.ai.isOn ? allCases : [.saveToDesktop]
    }

    var title: String {
        switch self {
        case .saveToDesktop: "Save to Desktop"
        case .sendToClaudeCode: "Send to Claude Code"
        }
    }

    var symbol: String {
        switch self {
        case .saveToDesktop: "menubar.dock.rectangle"
        case .sendToClaudeCode: "point.3.connected.trianglepath.dotted"
        }
    }
}

/// The search bar's page for a screenshot just taken: the picture as PNG data, and what can be done with it, narrowed by the search field to the ones whose name contains it, and the one selected.
@Observable final class ScreenshotPage {
    let png: Data
    private(set) var selected = 0

    init(png: Data) {
        self.png = png
    }

    func actions(matching query: String) -> [ScreenshotAction] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return ScreenshotAction.available }
        return ScreenshotAction.available.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    func selectedAction(matching query: String) -> ScreenshotAction? {
        let matching = actions(matching: query)
        return matching.indices.contains(selected) ? matching[selected] : nil
    }

    func select(_ index: Int) {
        selected = index
    }

    func moveSelection(by offset: Int, matching query: String) {
        let count = actions(matching: query).count
        guard count > 0 else { return }
        selected = min(max(selected + offset, 0), count - 1)
    }
}
