import Foundation

public struct InstalledApp: Identifiable, Hashable, Sendable {
    public let name: String
    public let url: URL

    public var id: URL { url }

    public var isRemovable: Bool { !url.path(percentEncoded: false).hasPrefix("/System/") }

    public init(url: URL) {
        self.url = url
        name = url.deletingPathExtension().lastPathComponent
    }

    public func match(for query: String) -> NameMatch? {
        NameMatch(name: name, query: query)
    }
}
