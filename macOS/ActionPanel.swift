import Foundation
import LauncherKit
import Observation

@Observable final class ActionPanel {
    enum Page {
        case actions, openWith, confirmDelete
    }

    enum Item: Hashable {
        case action(QuickLinkAction)
        case app(URL)
        case confirmDelete
        case cancel
    }

    let link: QuickLink
    private(set) var page: Page
    private(set) var selected = 0
    var filter = "" {
        didSet { selected = 0 }
    }

    init(link: QuickLink, page: Page = .actions) {
        self.link = link
        self.page = page
    }

    var title: String {
        page == .confirmDelete ? "Delete \(link.name)?" : link.name
    }

    var items: [Item] {
        switch page {
        case .actions:
            QuickLinkAction.matching(filter, appName: link.app?.appName).map(Item.action)
        case .openWith:
            link.appChoices.filter { filter.isEmpty || $0.appName.localizedStandardContains(filter) }.map(Item.app)
        case .confirmDelete:
            [.confirmDelete, .cancel]
        }
    }

    var selectedItem: Item? {
        items.indices.contains(selected) ? items[selected] : nil
    }

    func moveSelection(by offset: Int) {
        guard !items.isEmpty else { return }
        selected = min(max(selected + offset, 0), items.count - 1)
    }

    func show(_ page: Page) {
        self.page = page
        filter = ""
    }
}
