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

    public mutating func delete(_ link: QuickLink) {
        links.removeAll { $0.id == link.id }
    }

    private mutating func sort() {
        links.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
