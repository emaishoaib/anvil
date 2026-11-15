import Foundation

/// Where the search for an app's leftovers starts: the user's Library folder.
public struct SearchRoots: Sendable {
    public let library: URL

    public init(library: URL) {
        self.library = library
    }

    /// The folders of the user Anvil runs as.
    public static var current: SearchRoots {
        SearchRoots(library: .libraryDirectory)
    }
}
