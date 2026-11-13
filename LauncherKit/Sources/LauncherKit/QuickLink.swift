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
}
