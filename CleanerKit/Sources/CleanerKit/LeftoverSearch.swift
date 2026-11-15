import Foundation

/// Finds the files and folders an app has left behind, by looking one level deep in each search folder for names that belong to the app.
///
/// A name belongs when it matches the app's bundle ID, the bundle ID of a helper inside it or one of its app groups, when it is the app's bundle ID with the last part dropped, when it is a bundle-ID-style name ending in one of the app's names, when it is named after the app or its vendor, or when it is the app's file in the CrashReporter folder. The other installed apps are needed for the shorter bundle ID, the bundle-ID-style name and the vendor's name, so a file or folder that another app may share is left alone. A name that only matches one of the app's lone app groups is still found, but marked as possibly shared.
///
/// A folder that is missing or cannot be read is skipped, so a Library that Anvil can only partly read still gives back what it can. Leftovers come back in the order of `SearchFolder`, and by name within each folder.
public enum LeftoverSearch {
    public static func leftovers(of app: AppIdentity, in roots: SearchRoots, otherInstalledBundleIDs: Set<String>) -> [Leftover] {
        SearchFolder.allCases.flatMap { folder -> [Leftover] in
            guard let folderURL = folder.url(in: roots) else { return [] }
            return names(in: folderURL).sorted().compactMap { name in
                let belongs = app.identifiers.contains { BundleIDMatch.name(name, belongsTo: $0, in: folder) }
                    || ParentBundleIDMatch.name(name, belongsTo: app, otherInstalledBundleIDs: otherInstalledBundleIDs)
                    || ShortIDMatch.name(name, belongsTo: app, in: folder, otherInstalledBundleIDs: otherInstalledBundleIDs)
                    || NameMatch.name(name, belongsTo: app, in: folder, otherInstalledBundleIDs: otherInstalledBundleIDs)
                    || CrashReportMatch.name(name, belongsTo: app, in: folder)
                let belongsToLoneGroup = app.loneAppGroups.contains { BundleIDMatch.name(name, belongsTo: $0, in: folder) }
                guard belongs || belongsToLoneGroup else { return nil }
                return Leftover(url: folderURL.appending(path: name), folder: folder, mayBeShared: !belongs)
            }
        }
    }

    private static func names(in folder: URL) -> [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: folder.path(percentEncoded: false))) ?? []
    }
}
