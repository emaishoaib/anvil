import Foundation

/// Where the search for an app's leftovers starts: the user's Library folder, and the per-user cache and temp folders macOS keeps under `/var/folders`. A per-user folder that cannot be found is left out.
public struct SearchRoots: Sendable {
    public let library: URL
    public let userCache: URL?
    public let userTemp: URL?

    public init(library: URL, userCache: URL?, userTemp: URL?) {
        self.library = library
        self.userCache = userCache
        self.userTemp = userTemp
    }

    /// The folders of the user Anvil runs as.
    public static var current: SearchRoots {
        SearchRoots(library: .libraryDirectory, userCache: perUserFolder(_CS_DARWIN_USER_CACHE_DIR), userTemp: perUserFolder(_CS_DARWIN_USER_TEMP_DIR))
    }

    /// A folder under `/var/folders` whose path is different on every Mac, so macOS is asked for it.
    private static func perUserFolder(_ name: Int32) -> URL? {
        let length = confstr(name, nil, 0)
        guard length > 0 else { return nil }
        var path = [CChar](repeating: 0, count: length)
        guard confstr(name, &path, length) == length else { return nil }
        return URL(filePath: String(decoding: path.prefix { $0 != 0 }.map(UInt8.init(bitPattern:)), as: UTF8.self), directoryHint: .isDirectory)
    }
}
