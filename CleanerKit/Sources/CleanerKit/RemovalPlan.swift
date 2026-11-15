import Foundation

/// What uninstalling an app would move to the Trash: the app itself first, then each file it left behind, every one measured in bytes.
///
/// The app is looked through for the helpers it carries and the app groups it uses, so their files are found too. Apple's own apps are not looked through, because their helpers and groups are shared across the system. The other installed apps are read for their bundle IDs and app groups, so a vendor folder, a helper or a group one of them may share is left out. Once the leftovers are known, the browsers' native messaging files that point into the app or one of its leftovers come next. The files found by name elsewhere on the Mac come last, leaving out any that have gone since the walk found them. A leftover in the home folder starts unticked, because it may hold the user's own files, and so does one found only through a lone app group, because it may belong to another program. An app without a bundle ID has no leftovers that can be told apart from other apps' files, so only the app itself is listed.
///
/// A file found by name starts ticked only when it sits right inside one of the places apps keep their files, such as Caches or a folder of the Library shared by every user, and Anvil can move it. One buried deeper, such as inside another vendor's folder, or one among the user's own files starts unticked. A file that is also found by the search folders, or that sits inside another file on the list, is listed only once, as the outermost one.
public enum RemovalPlan {
    public static func items(forAppAt appURL: URL, in roots: SearchRoots, otherAppURLs: [URL], foundByName: [URL] = []) -> [RemovalItem] {
        let appItem = RemovalItem(url: appURL, kind: .app, sizeBytes: DiskSize.bytes(at: appURL))
        guard let identity = AppIdentity(appAt: appURL) else { return [appItem] }
        let others = otherAppURLs.compactMap(AppIdentity.init(appAt:))
        let app = withContents(of: identity, at: appURL, otherAppURLs: otherAppURLs, others: others)
        let found = LeftoverSearch.leftovers(of: app, in: roots, otherInstalledBundleIDs: Set(others.map(\.bundleID)))
        let hostFiles = NativeMessagingHosts.files(in: roots, pointingInto: [appURL] + found.map(\.url) + foundByName)
        let leftovers = (found + hostFiles).map { leftover in
            let startsTicked = !leftover.folder.mayHoldUserFiles && !leftover.mayBeShared
            return RemovalItem(url: leftover.url, kind: .leftover(leftover.folder), sizeBytes: DiskSize.bytes(at: leftover.url), startsTicked: startsTicked)
        }
        let namedAfterApp = foundByName.filter(exists).sorted { $0.path(percentEncoded: false) < $1.path(percentEncoded: false) }.map { url in
            RemovalItem(url: url, kind: .foundByName, sizeBytes: DiskSize.bytes(at: url), startsTicked: startsTicked(foundByName: url, in: roots))
        }
        return outermost([appItem] + leftovers + namedAfterApp)
    }

    /// The app's other names include the names of the apps nested inside it that start with one of its names, such as `Docker Desktop` inside Docker. An other name is dropped when another installed app goes by the same name, because a file named after it could be that app's.
    private static func withContents(of identity: AppIdentity, at appURL: URL, otherAppURLs: [URL], others: [AppIdentity]) -> AppIdentity {
        let namesOfOtherApps = Set(others.flatMap(\.allNames).map { $0.lowercased() })
        let unshared = { (names: Set<String>) in names.filter { !namesOfOtherApps.contains($0.lowercased()) } }
        guard !identity.isApple else { return identity.with(otherNames: unshared(identity.otherNames), helperBundleIDs: [], appGroups: .none) }
        let nestedBundles = NestedBundles.urls(inAppAt: appURL)
        let nestedAppNames = NestedBundles.appNames(in: nestedBundles, startingWithAnyOf: identity.allNames)
        let otherNames = unshared(identity.otherNames.union(AppIdentity.names(nestedAppNames, besides: identity.name)))
        let teamID = CodeSignature(bundleAt: appURL).teamID
        let helpers = HelperBundleIDs.of(identity, nestedBundles: nestedBundles, teamID: teamID, otherAppURLs: otherAppURLs)
        let groups = AppGroups.of(bundles: [appURL] + nestedBundles, otherAppURLs: otherAppURLs)
        return identity.with(otherNames: otherNames, helperBundleIDs: helpers, appGroups: groups)
    }

    /// Whether a file is still on disk. A link counts even when what it points to is gone.
    public static func exists(_ url: URL) -> Bool {
        (try? FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))) != nil
    }

    private static func startsTicked(foundByName url: URL, in roots: SearchRoots) -> Bool {
        let parent = pathKey(url.deletingLastPathComponent())
        let appPlaces = SearchFolder.allCases.filter { !$0.mayHoldUserFiles }.compactMap { $0.url(in: roots) }.map(pathKey)
        let isInAppPlace = appPlaces.contains(parent) || pathKey(url.deletingLastPathComponent().deletingLastPathComponent()) == pathKey(roots.systemLibrary)
        return isInAppPlace && FileManager.default.isDeletableFile(atPath: url.path(percentEncoded: false))
    }

    /// The items with each one that repeats an earlier item, or sits inside another item, left out.
    private static func outermost(_ items: [RemovalItem]) -> [RemovalItem] {
        let paths = items.map { pathKey($0.url) }
        var seen: Set<[String]> = []
        return zip(items, paths).filter { _, path in
            let isInsideAnother = paths.contains { path.count > $0.count && path.starts(with: $0) }
            return !isInsideAnother && seen.insert(path).inserted
        }.map(\.0)
    }

    /// A path in a form that compares equal however it was reached, because a walk of the Mac gives back `/var` paths as `/private/var` while macOS names the per-user folders under `/var`.
    private static func pathKey(_ url: URL) -> [String] {
        url.resolvingSymlinksInPath().standardizedFileURL.pathComponents
    }
}
