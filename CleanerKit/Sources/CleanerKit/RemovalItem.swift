import Foundation

/// One thing an uninstall would move to the Trash: the app itself, a file it left behind in one of the search folders, or a file named after it found elsewhere on the Mac, with its size in bytes. An item starts ticked unless it may hold the user's own files, in which case it is only moved when the user ticks it.
public struct RemovalItem: Hashable, Identifiable, Sendable {
    public enum Kind: Hashable, Sendable {
        case app
        case leftover(SearchFolder)
        case foundByName
    }

    public let url: URL
    public let kind: Kind
    public let sizeBytes: Int64
    public let startsTicked: Bool

    public init(url: URL, kind: Kind, sizeBytes: Int64, startsTicked: Bool = true) {
        self.url = url
        self.kind = kind
        self.sizeBytes = sizeBytes
        self.startsTicked = startsTicked
    }

    public var id: URL { url }

    public var name: String { url.lastPathComponent }
}
