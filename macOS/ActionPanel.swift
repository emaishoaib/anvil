import Foundation
import LauncherKit
import Observation

@Observable final class ActionPanel {
    enum Subject {
        case quickLink(QuickLink)
        case anvil

        var link: QuickLink? {
            if case .quickLink(let link) = self { link } else { nil }
        }
    }

    enum Page {
        case actions, openWith, confirmDelete
    }

    enum Item: Hashable {
        case action(QuickLinkAction)
        case app(URL)
        case confirmDelete
        case cancel
        case anvil(AnvilAction)
    }

    private static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

    let subject: Subject
    private(set) var page: Page
    private(set) var selected = 0
    var filter = "" {
        didSet { selected = 0 }
    }

    init(subject: Subject, page: Page = .actions) {
        self.subject = subject
        self.page = page
    }

    var link: QuickLink? { subject.link }

    var title: String {
        switch subject {
        case .quickLink(let link): page == .confirmDelete ? "Delete \(link.name)?" : link.name
        case .anvil: "Anvil v\(Self.version)"
        }
    }

    var items: [Item] {
        switch (subject, page) {
        case (.anvil, _):
            AnvilAction.matching(filter).map(Item.anvil)
        case (.quickLink(let link), .actions):
            QuickLinkAction.matching(filter, appName: link.app?.appName).map(Item.action)
        case (.quickLink(let link), .openWith):
            link.appChoices.filter { filter.isEmpty || $0.appName.localizedStandardContains(filter) }.map(Item.app)
        case (.quickLink, .confirmDelete):
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
