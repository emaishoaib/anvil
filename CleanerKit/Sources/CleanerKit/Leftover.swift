import Foundation

/// A file or folder in the Library that belongs to an app, and the Library folder it was found in.
public struct Leftover: Hashable, Sendable {
    public let url: URL
    public let folder: LibraryFolder
}
