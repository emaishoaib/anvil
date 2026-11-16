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

    public mutating func merge(_ incoming: [QuickLink]) -> (added: Int, updated: Int, skipped: Int) {
        var added = 0
        var updated = 0
        for link in incoming {
            guard let index = links.firstIndex(where: { $0.name == link.name && $0.link == link.link }) else {
                links.append(link)
                added += 1
                continue
            }
            guard links[index].openWith != link.openWith else { continue }
            links[index].openWith = link.openWith
            updated += 1
        }
        sort()
        return (added, updated, incoming.count - added - updated)
    }

    public mutating func delete(_ link: QuickLink) {
        links.removeAll { $0.id == link.id }
    }

    private mutating func sort() {
        links.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
