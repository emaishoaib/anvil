import Foundation

/// Finds the files and folders an app has left in a Library, by looking one level deep in each Library folder for names that belong to the app's bundle ID.
///
/// A folder that is missing or cannot be read is skipped, so a Library that Anvil can only partly read still gives back what it can. Leftovers come back in the order of `LibraryFolder`, and by name within each folder.
public enum LeftoverSearch {
    public static func leftovers(of bundleID: String, inLibrary library: URL) -> [Leftover] {
        LibraryFolder.allCases.flatMap { folder in
            let folderURL = folder.url(inLibrary: library)
            return names(in: folderURL)
                .filter { BundleIDMatch.name($0, belongsTo: bundleID, in: folder) }
                .sorted()
                .map { Leftover(url: folderURL.appending(path: $0), folder: folder) }
        }
    }

    private static func names(in folder: URL) -> [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: folder.path(percentEncoded: false))) ?? []
    }
}
