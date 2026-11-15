import Foundation

/// Finds the files and folders an app has left in a Library, by looking one level deep in each Library folder for names that belong to the app.
///
/// A name belongs when it matches the app's bundle ID, or when it is named after the app or its vendor. The other installed apps are needed for the second kind, so a vendor's folder that another app may share is left alone.
///
/// A folder that is missing or cannot be read is skipped, so a Library that Anvil can only partly read still gives back what it can. Leftovers come back in the order of `LibraryFolder`, and by name within each folder.
public enum LeftoverSearch {
    public static func leftovers(of app: AppIdentity, inLibrary library: URL, otherInstalledBundleIDs: Set<String>) -> [Leftover] {
        LibraryFolder.allCases.flatMap { folder in
            let folderURL = folder.url(inLibrary: library)
            return names(in: folderURL)
                .filter { name in
                    BundleIDMatch.name(name, belongsTo: app.bundleID, in: folder)
                        || NameMatch.name(name, belongsTo: app, in: folder, otherInstalledBundleIDs: otherInstalledBundleIDs)
                }
                .sorted()
                .map { Leftover(url: folderURL.appending(path: $0), folder: folder) }
        }
    }

    private static func names(in folder: URL) -> [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: folder.path(percentEncoded: false))) ?? []
    }
}
