import Foundation

/// Walks folders and everything under them, showing each file and folder to a visitor that decides whether to go inside a folder. It reads folders the way `find` does, through `fts`, and gives the visitor each name without building a URL for it, because a walk of the Mac passes millions of names and keeps only a few.
///
/// The walk never goes inside a bundle, such as an app, a framework or an SDK, or inside another package, such as a Photos library, because what is inside one belongs to it rather than sitting beside it. It never goes into another volume mounted inside a folder either. A folder that cannot be read is skipped.
public enum DiskWalk {
    public enum Step: Sendable {
        case goInside
        case stayOutside
    }

    /// One file or folder the walk passes. Its URL is built only when asked for, and can only be asked for while the visitor is looking at it.
    public struct Item {
        public let name: String
        public let isFolder: Bool
        fileprivate let path: UnsafeMutablePointer<CChar>

        public var url: URL {
            URL(fileURLWithFileSystemRepresentation: path, isDirectory: isFolder, relativeTo: nil)
        }
    }

    /// The folders of the Mac where apps and their installers leave files. macOS's own System folder is left out, and so is Volumes, which holds the other drives.
    public static let macFolders = ["/Applications", "/Library", "/Users", "/private", "/opt", "/usr/local"].map { URL(filePath: $0, directoryHint: .isDirectory) }

    private static let bundleExtensions: Set<String> = ["app", "appex", "bundle", "framework", "kext", "plugin", "sdk", "xcframework", "xpc"]
    private static let options = FTS_PHYSICAL | FTS_NOCHDIR | FTS_XDEV | FTS_NOSTAT

    public static func walk(_ folders: [URL], visit: (Item) -> Step) {
        let paths = folders.map { strdup($0.path(percentEncoded: false)) }
        defer { paths.forEach { free($0) } }
        guard let stream = (paths + [nil]).withUnsafeBufferPointer({ fts_open($0.baseAddress, options, nil) }) else { return }
        defer { fts_close(stream) }
        while let entry = fts_read(stream) {
            guard let item = item(at: entry) else { continue }
            if visit(item) == .stayOutside || (item.isFolder && isSealed(item)) {
                _ = fts_set(stream, entry, FTS_SKIP)
            }
        }
    }

    /// The file or folder an `fts` entry stands for, or nothing for the folders the walk starts from, for a folder it is leaving, and for an entry it could not read at all.
    private static func item(at entry: UnsafeMutablePointer<FTSENT>) -> Item? {
        let info = Int32(entry.pointee.fts_info)
        guard entry.pointee.fts_level > 0, info != FTS_DP, info != FTS_ERR, let path = entry.pointee.fts_path else { return nil }
        let nameStart = path + Int(entry.pointee.fts_pathlen) - Int(entry.pointee.fts_namelen)
        return Item(name: String(cString: nameStart), isFolder: info == FTS_D, path: path)
    }

    /// Whether the walk stays outside a folder whatever the visitor says, because it is a bundle or another package. Only a folder whose name has an extension is asked about, so most folders cost nothing extra.
    private static func isSealed(_ folder: Item) -> Bool {
        guard let dot = folder.name.lastIndex(of: "."), dot != folder.name.startIndex else { return false }
        let pathExtension = folder.name[folder.name.index(after: dot)...].lowercased()
        return bundleExtensions.contains(pathExtension) || (try? folder.url.resourceValues(forKeys: [.isPackageKey]).isPackage) == true
    }
}
