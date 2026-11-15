import Foundation
import LauncherKit
import Observation
import RulesKit

@Observable final class ActionPanel {
    enum Subject {
        case quickLink(QuickLink)
        case anvil
        case settingChoices(Setting)
        case rule(Rule)

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
        case choice(index: Int, title: String, isCurrent: Bool)
        case ruleAction(RuleRowAction)
        case confirmRuleDelete
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
        if case .settingChoices(let setting) = subject, case .choice(let current, _, _) = setting.row { selected = current }
    }

    var link: QuickLink? { subject.link }

    var title: String {
        switch subject {
        case .quickLink(let link): page == .confirmDelete ? "Delete \(link.name)?" : link.name
        case .anvil: "Anvil v\(Self.version)"
        case .settingChoices(let setting): setting.entry.title
        case .rule(let rule): page == .confirmDelete ? "Delete this rule?" : "\(rule.trigger.text), \(rule.action.text)"
        }
    }

    var filterPlaceholder: String {
        switch (subject, page) {
        case (_, .openWith): "Search for apps…"
        case (.settingChoices, _): "Search for choices…"
        default: "Search for actions…"
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
        case (.settingChoices(let setting), _):
            Self.choices(of: setting, matching: filter)
        case (.rule, .confirmDelete):
            [.confirmRuleDelete, .cancel]
        case (.rule, _):
            RuleRowAction.matching(filter).map(Item.ruleAction)
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

    private static func choices(of setting: Setting, matching filter: String) -> [Item] {
        guard case .choice(let current, let options, _) = setting.row else { return [] }
        return options.enumerated()
            .filter { filter.isEmpty || $0.element.localizedStandardContains(filter) }
            .map { Item.choice(index: $0.offset, title: $0.element, isCurrent: $0.offset == current) }
    }
}
