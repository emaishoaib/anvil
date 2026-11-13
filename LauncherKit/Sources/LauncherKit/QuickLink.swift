import Foundation

public struct QuickLink: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var name: String
    public var link: String
    public var openWith: URL?

    public init(id: UUID = UUID(), name: String = "", link: String = "", openWith: URL? = nil) {
        self.id = id
        self.name = name
        self.link = link
        self.openWith = openWith
    }

    public var launchKey: String { "quickLink:\(id.uuidString)" }

    public var isComplete: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !link.trimmingCharacters(in: .whitespaces).isEmpty
    }

    public var isFilePath: Bool {
        link.hasPrefix("/") || link.hasPrefix("~")
    }

    public var scheme: String? {
        guard !isFilePath, let colon = link.firstIndex(of: ":") else { return nil }
        let scheme = link[..<colon]
        guard let first = scheme.first, first.isLetter, scheme.allSatisfy({ $0.isLetter || $0.isNumber || "+-.".contains($0) }) else { return nil }
        return scheme.lowercased()
    }

    public var host: String? {
        guard scheme != nil, let start = link.range(of: "://")?.upperBound else { return nil }
        let authority = link[start...].prefix { !"/?#".contains($0) }
        guard let host = authority.split(separator: "@").last?.split(separator: ":").first?.lowercased() else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    public var target: URL? {
        if isFilePath { return URL(filePath: (link as NSString).expandingTildeInPath) }
        return URL(string: link)
    }

    public func match(for query: String) -> NameMatch? {
        NameMatch(name: name, query: query)
    }
}
