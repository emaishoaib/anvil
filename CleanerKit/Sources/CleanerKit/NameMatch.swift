/// Whether a name in one of the search folders belongs to an app because it is named after the app or its vendor, such as `Spotify` in Application Support. Any of the app's names counts, so Visual Studio Code also finds `Code`.
///
/// Only the folders where apps make folders under plain names are checked this way. Names are compared ignoring letter case and spaces, so an app called `Visual Notes` also finds `VisualNotes`. In the home folder the name may also start with a dot, as in `.docker`, because apps often hide their folders there. In the folders where apps also keep loose files, such as Logs and Preferences, a file named after the app with a file extension counts too, such as `Folx.log`.
///
/// Four rules keep this from catching another app's files or the user's own:
/// - Apple's own apps are never matched this way, and no name starting with `com.apple.` ever is
/// - a vendor's folder only belongs to the app when no other installed app comes from the same vendor, because the folder may hold that app's files too
/// - a bundle ID with fewer than three parts has no vendor to match
/// - in the home folder only the app's file name counts, not its other names or its vendor, and the folders macOS makes there, such as Documents and Downloads, never match
enum NameMatch {
    private static let standardHomeFolders: Set<String> = ["applications", "desktop", "documents", "downloads", "library", "movies", "music", "pictures", "public"]

    private static let maximumExtensionLength = 8

    static func name(_ name: String, belongsTo app: AppIdentity, in folder: SearchFolder, otherInstalledBundleIDs: Set<String>) -> Bool {
        guard !app.isApple, !name.lowercased().hasPrefix("com.apple.") else { return false }
        if folder.holdsFilesNamedAfterApps, let baseName = withoutExtension(name), app.allNames.contains(where: { squashed($0) == squashed(baseName) }) { return true }
        guard folder.holdsFoldersNamedAfterApps else { return false }
        guard folder != .home || !standardHomeFolders.contains(name.lowercased()) else { return false }
        let squashedName = squashed(name)
        let squashedAppName = squashed(app.name)
        guard folder != .home else { return squashedName == squashedAppName || squashedName == "." + squashedAppName }
        let isNamedAfterApp = app.allNames.contains { squashed($0) == squashedName }
        guard folder.holdsFoldersNamedAfterVendors else { return isNamedAfterApp }
        let isNamedAfterVendor = app.vendor.map { vendor in
            squashedName == vendor && !isShared(vendor, by: otherInstalledBundleIDs, besides: app)
        } ?? false
        return isNamedAfterApp || isNamedAfterVendor
    }

    private static func isShared(_ vendor: String, by bundleIDs: Set<String>, besides app: AppIdentity) -> Bool {
        bundleIDs.contains { bundleID in
            bundleID.lowercased() != app.bundleID.lowercased() && AppIdentity.vendor(of: bundleID) == vendor
        }
    }

    /// The name without its file extension, or nothing when it has none. An extension is a dot followed by up to eight letters or digits at the end, such as `.log` or `.plist`.
    private static func withoutExtension(_ name: String) -> String? {
        guard let dot = name.lastIndex(of: "."), dot != name.startIndex else { return nil }
        let fileExtension = name[name.index(after: dot)...]
        guard !fileExtension.isEmpty, fileExtension.count <= maximumExtensionLength, fileExtension.allSatisfy({ $0.isLetter || $0.isNumber }) else { return nil }
        return String(name[..<dot])
    }

    private static func squashed(_ name: String) -> String {
        name.lowercased().filter { !$0.isWhitespace }
    }
}
