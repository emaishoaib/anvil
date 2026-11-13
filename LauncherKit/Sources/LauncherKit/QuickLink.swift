import Foundation

public struct QuickLink: Identifiable, Hashable, Codable, Sendable {
    public static let placeholderLimit = 3

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

    public var duplicate: QuickLink {
        QuickLink(name: "\(name) copy", link: link, openWith: openWith)
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

    public var placeholders: [String] {
        var names: [String] = []
        for match in link.matches(of: /\{([^{}]+)\}/) where !names.contains(String(match.1)) {
            names.append(String(match.1))
        }
        return Array(names.prefix(Self.placeholderLimit))
    }

    public var target: URL? { target(filling: []) }

    public func target(filling values: [String]) -> URL? {
        var filled = link
        for (name, value) in zip(placeholders, values) {
            filled = filled.replacingOccurrences(of: "{\(name)}", with: isFilePath ? value : Self.encoded(value))
        }
        filled.replace(/\{[^{}]+\}/, with: "")
        if isFilePath { return URL(filePath: (filled as NSString).expandingTildeInPath) }
        return URL(string: filled)
    }

    public func match(for query: String) -> NameMatch? {
        NameMatch(name: name, query: query)
    }

    private static func encoded(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(CharacterSet(charactersIn: "-._~"))) ?? value
    }
}
