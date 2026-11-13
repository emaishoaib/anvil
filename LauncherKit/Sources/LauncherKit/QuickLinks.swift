import Foundation

public struct QuickLinks: Equatable, Sendable {
    public private(set) var links: [QuickLink]

    public init(_ links: [QuickLink] = []) {
        self.links = links
        sort()
    }

    public mutating func save(_ link: QuickLink) {
        if let index = links.firstIndex(where: { $0.id == link.id }) {
            links[index] = link
        } else {
            links.append(link)
        }
        sort()
    }

    public mutating func add(_ incoming: [QuickLink]) -> (added: Int, skipped: Int) {
        var added = 0
        for link in incoming where !links.contains(where: { $0.name == link.name && $0.link == link.link }) {
            links.append(link)
            added += 1
        }
        sort()
        return (added, incoming.count - added)
    }

    public mutating func delete(_ link: QuickLink) {
        links.removeAll { $0.id == link.id }
    }

    private mutating func sort() {
        links.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
