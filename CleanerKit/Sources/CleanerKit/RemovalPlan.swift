import Foundation

/// What uninstalling an app would move to the Trash: the app itself first, then each file it left behind, every one measured in bytes.
///
/// The app is looked through for the helpers it carries and the app groups it uses, so their files are found too. Apple's own apps are not looked through, because their helpers and groups are shared across the system. The other installed apps are read for their bundle IDs and app groups, so a vendor folder, a helper or a group one of them may share is left out. Once the leftovers are known, the browsers' native messaging files that point into the app or one of its leftovers come last. A leftover in the home folder starts unticked, because it may hold the user's own files. An app without a bundle ID has no leftovers that can be told apart from other apps' files, so only the app itself is listed.
public enum RemovalPlan {
    public static func items(forAppAt appURL: URL, in roots: SearchRoots, otherAppURLs: [URL]) -> [RemovalItem] {
        let appItem = RemovalItem(url: appURL, kind: .app, sizeBytes: DiskSize.bytes(at: appURL))
        guard let identity = AppIdentity(appAt: appURL) else { return [appItem] }
        let others = otherAppURLs.compactMap(AppIdentity.init(appAt:))
        let app = withContents(of: identity, at: appURL, otherAppURLs: otherAppURLs, others: others)
        let found = LeftoverSearch.leftovers(of: app, in: roots, otherInstalledBundleIDs: Set(others.map(\.bundleID)))
        let hostFiles = NativeMessagingHosts.files(in: roots, pointingInto: [appURL] + found.map(\.url))
        let leftovers = (found + hostFiles).map { leftover in
            RemovalItem(url: leftover.url, kind: .leftover(leftover.folder), sizeBytes: DiskSize.bytes(at: leftover.url), startsTicked: !leftover.folder.mayHoldUserFiles)
        }
        return [appItem] + leftovers
    }

    /// The app's executable name is dropped when another installed app is named or runs under the same name, because a file named after it could be that app's.
    private static func withContents(of identity: AppIdentity, at appURL: URL, otherAppURLs: [URL], others: [AppIdentity]) -> AppIdentity {
        let otherProgramNames = Set(others.flatMap { [$0.name, $0.executableName].compactMap { $0?.lowercased() } })
        let executableName = identity.executableName.flatMap { otherProgramNames.contains($0.lowercased()) ? nil : $0 }
        guard !identity.isApple else { return identity.with(executableName: executableName, helperBundleIDs: [], appGroups: []) }
        let nestedBundles = NestedBundles.urls(inAppAt: appURL)
        let teamID = CodeSignature(bundleAt: appURL).teamID
        let helpers = HelperBundleIDs.of(identity, nestedBundles: nestedBundles, teamID: teamID, otherAppURLs: otherAppURLs)
        let groups = AppGroups.of(bundles: [appURL] + nestedBundles, otherAppURLs: otherAppURLs)
        return identity.with(executableName: executableName, helperBundleIDs: helpers, appGroups: groups)
    }
}
