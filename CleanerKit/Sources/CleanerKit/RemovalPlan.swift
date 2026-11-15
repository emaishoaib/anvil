import Foundation

/// What uninstalling an app would move to the Trash: the app itself first, then each file it left in the Library, every one measured in bytes.
///
/// The app is looked through for the helpers it carries, so their files are found too. The other installed apps are read for their bundle IDs, so a vendor folder or a helper one of them may share is left out. An app without a bundle ID has no leftovers that can be told apart from other apps' files, so only the app itself is listed.
public enum RemovalPlan {
    public static func items(forAppAt appURL: URL, inLibrary library: URL, otherAppURLs: [URL]) -> [RemovalItem] {
        let appItem = RemovalItem(url: appURL, kind: .app, sizeBytes: DiskSize.bytes(at: appURL))
        guard let identity = AppIdentity(appAt: appURL) else { return [appItem] }
        let helpers = HelperBundleIDs.of(identity, at: appURL, otherAppURLs: otherAppURLs)
        let app = AppIdentity(bundleID: identity.bundleID, name: identity.name, helperBundleIDs: helpers)
        let otherBundleIDs = Set(otherAppURLs.compactMap { AppIdentity(appAt: $0)?.bundleID })
        let leftovers = LeftoverSearch.leftovers(of: app, inLibrary: library, otherInstalledBundleIDs: otherBundleIDs).map { leftover in
            RemovalItem(url: leftover.url, kind: .leftover(leftover.folder), sizeBytes: DiskSize.bytes(at: leftover.url))
        }
        return [appItem] + leftovers
    }
}
