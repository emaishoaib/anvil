/// Whether a name in one of the search folders belongs to an app, judged only by the app's bundle ID.
///
/// A name belongs when it is the bundle ID itself, or the bundle ID followed by a dot and more, such as `com.example.app.plist` or `com.example.app.savedState`. A name that only starts with the same letters, such as `com.example.application`, does not belong. In Group Containers, Containers and Application Scripts a name also belongs when the bundle ID follows a team or group prefix, such as `group.com.example.app` or `ABCDE12345.com.example.app`. Letter case is ignored, because the Mac's disk ignores it too. An empty bundle ID matches nothing.
enum BundleIDMatch {
    private static let foldersNamedWithPrefixes: Set<SearchFolder> = [.groupContainers, .containers, .applicationScripts]

    static func name(_ name: String, belongsTo bundleID: String, in folder: SearchFolder) -> Bool {
        guard !bundleID.isEmpty else { return false }
        let name = name.lowercased()
        let bundleID = bundleID.lowercased()
        let startsWithBundleID = name == bundleID || name.hasPrefix(bundleID + ".")
        let followsPrefix = foldersNamedWithPrefixes.contains(folder) && name.hasSuffix("." + bundleID)
        return startsWithBundleID || followsPrefix
    }
}
