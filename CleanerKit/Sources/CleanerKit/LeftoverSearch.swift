import Foundation

/// Finds the files and folders an app has left behind, by looking one level deep in each search folder for names that belong to the app.
///
/// A name belongs when it matches the app's bundle ID, the bundle ID of a helper inside it or one of its app groups, when it is named after the app or its vendor, or when it is the app's file in the CrashReporter folder. The other installed apps are needed for the second kind, so a vendor's folder that another app may share is left alone.
///
/// A folder that is missing or cannot be read is skipped, so a Library that Anvil can only partly read still gives back what it can. Leftovers come back in the order of `SearchFolder`, and by name within each folder.
public enum LeftoverSearch {
    public static func leftovers(of app: AppIdentity, in roots: SearchRoots, otherInstalledBundleIDs: Set<String>) -> [Leftover] {
        SearchFolder.allCases.flatMap { folder -> [Leftover] in
            guard let folderURL = folder.url(in: roots) else { return [] }
            return names(in: folderURL)
                .filter { name in
                    app.identifiers.contains { BundleIDMatch.name(name, belongsTo: $0, in: folder) }
                        || NameMatch.name(name, belongsTo: app, in: folder, otherInstalledBundleIDs: otherInstalledBundleIDs)
                        || CrashReportMatch.name(name, belongsTo: app, in: folder)
                }
                .sorted()
                .map { Leftover(url: folderURL.appending(path: $0), folder: folder) }
        }
    }

    private static func names(in folder: URL) -> [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: folder.path(percentEncoded: false))) ?? []
    }
}
