import Foundation

/// One thing an uninstall would move to the Trash: the app itself, or a file it left behind, with its size in bytes.
public struct RemovalItem: Hashable, Identifiable, Sendable {
    public enum Kind: Hashable, Sendable {
        case app
        case leftover(SearchFolder)
    }

    public let url: URL
    public let kind: Kind
    public let sizeBytes: Int64

    public var id: URL { url }

    public var name: String { url.lastPathComponent }
}
