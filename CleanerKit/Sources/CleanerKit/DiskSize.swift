import Foundation

/// The size of a file, or of a folder and everything inside it, as the total length of its files in bytes. A path that is missing or cannot be read counts as zero.
public enum DiskSize {
    public static func bytes(at url: URL) -> Int64 {
        guard let isFolder = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory else { return 0 }
        guard isFolder else { return fileBytes(at: url) }
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        var total: Int64 = 0
        for case let file as URL in enumerator {
            total += fileBytes(at: file)
        }
        return total
    }

    private static func fileBytes(at url: URL) -> Int64 {
        Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
    }
}
