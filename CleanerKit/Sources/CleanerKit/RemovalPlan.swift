import Foundation

/// What uninstalling an app would move to the Trash: the app itself first, then each file it left in the Library, every one measured in bytes.
///
/// The app is looked through for the helpers it carries and the app groups it uses, so their files are found too. Apple's own apps are not looked through, because their helpers and groups are shared across the system. The other installed apps are read for their bundle IDs and app groups, so a vendor folder, a helper or a group one of them may share is left out. An app without a bundle ID has no leftovers that can be told apart from other apps' files, so only the app itself is listed.
public enum RemovalPlan {
    public static func items(forAppAt appURL: URL, inLibrary library: URL, otherAppURLs: [URL]) -> [RemovalItem] {
        let appItem = RemovalItem(url: appURL, kind: .app, sizeBytes: DiskSize.bytes(at: appURL))
        guard let identity = AppIdentity(appAt: appURL) else { return [appItem] }
        let app = identity.isApple ? identity : withContents(of: identity, at: appURL, otherAppURLs: otherAppURLs)
        let otherBundleIDs = Set(otherAppURLs.compactMap { AppIdentity(appAt: $0)?.bundleID })
        let leftovers = LeftoverSearch.leftovers(of: app, inLibrary: library, otherInstalledBundleIDs: otherBundleIDs).map { leftover in
            RemovalItem(url: leftover.url, kind: .leftover(leftover.folder), sizeBytes: DiskSize.bytes(at: leftover.url))
        }
        return [appItem] + leftovers
    }

    private static func withContents(of identity: AppIdentity, at appURL: URL, otherAppURLs: [URL]) -> AppIdentity {
        let nestedBundles = NestedBundles.urls(inAppAt: appURL)
        let teamID = CodeSignature(bundleAt: appURL).teamID
        let helpers = HelperBundleIDs.of(identity, nestedBundles: nestedBundles, teamID: teamID, otherAppURLs: otherAppURLs)
        let groups = AppGroups.of(bundles: [appURL] + nestedBundles, otherAppURLs: otherAppURLs)
        return AppIdentity(bundleID: identity.bundleID, name: identity.name, helperBundleIDs: helpers, appGroups: groups)
    }
}
