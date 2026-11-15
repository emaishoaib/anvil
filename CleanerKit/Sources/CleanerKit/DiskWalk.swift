import Foundation

/// Walks folders and everything under them, showing each file and folder to a visitor that decides whether to go inside a folder. The walk never goes inside a bundle, such as an app, a framework or an SDK, because what is inside one belongs to the bundle rather than sitting beside it. It never goes into another volume mounted inside a folder either. A folder that cannot be read is skipped.
public enum DiskWalk {
    public enum Step: Sendable {
        case goInside
        case stayOutside
    }

    /// The folders of the Mac where apps and their installers leave files. macOS's own System folder is left out, and so is Volumes, which holds the other drives.
    public static let macFolders = ["/Applications", "/Library", "/Users", "/private", "/opt", "/usr/local"].map { URL(filePath: $0, directoryHint: .isDirectory) }

    private static let bundleExtensions: Set<String> = ["app", "appex", "bundle", "framework", "kext", "plugin", "sdk", "xcframework", "xpc"]

    public static func walk(_ folders: [URL], visit: (URL) -> Step) {
        for folder in folders {
            guard let enumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: [.isVolumeKey], options: .skipsPackageDescendants) else { continue }
            for case let item as URL in enumerator {
                guard visit(item) == .goInside, !isSealed(item) else {
                    enumerator.skipDescendants()
                    continue
                }
            }
        }
    }

    /// Whether the walk stays outside a folder whatever the visitor says, because it is a bundle or another volume.
    private static func isSealed(_ item: URL) -> Bool {
        bundleExtensions.contains(item.pathExtension.lowercased()) || (try? item.resourceValues(forKeys: [.isVolumeKey]).isVolume) == true
    }
}
