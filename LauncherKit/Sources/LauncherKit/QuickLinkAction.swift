import Foundation

public enum QuickLinkAction: CaseIterable, Sendable {
    case open, openWith, edit, duplicate, resetRanking, copyName, copyLink, delete

    public enum Group: Sendable {
        case opening, ranking, copying, deleting
    }

    public var group: Group {
        switch self {
        case .open, .openWith, .edit, .duplicate: .opening
        case .resetRanking: .ranking
        case .copyName, .copyLink: .copying
        case .delete: .deleting
        }
    }

    public var isDestructive: Bool { self == .delete }

    public func name(openingIn appName: String?) -> String {
        switch self {
        case .open: appName.map { "Open in \($0)" } ?? "Open Quick Link"
        case .openWith: "Open With…"
        case .edit: "Edit Quick Link"
        case .duplicate: "Duplicate Quick Link"
        case .resetRanking: "Reset Ranking"
        case .copyName: "Copy Name"
        case .copyLink: "Copy Link"
        case .delete: "Delete Quick Link"
        }
    }

    public static func matching(_ filter: String, appName: String?) -> [QuickLinkAction] {
        let filter = filter.trimmingCharacters(in: .whitespaces)
        guard !filter.isEmpty else { return allCases }
        return allCases.filter { NameMatch(name: $0.name(openingIn: appName), query: filter) != nil }
    }
}
