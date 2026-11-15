/// Whether a name belongs to an app because it is a bundle-ID-style name ending in one of the app's names, such as `io.mpv.plist` for mpv or `hughkli.Lookin` for Lookin. Some apps keep their files under a shorter or older ID than the bundle ID they ship with.
///
/// The name may end in one of the suffixes macOS and apps add to such names, such as `.plist` or `.savedState`, and what is left must have at least two parts. Its last part must equal one of the app's names, ignoring letter case and spaces.
///
/// Three rules keep this from catching another app's files or the user's own:
/// - the home folder and the CrashReporter folder are never checked this way
/// - Apple's own apps are never matched this way, and no name starting with `com.apple.` ever is
/// - a name that is another installed app's bundle ID, or starts with one, is left to that app
enum ShortIDMatch {
    private static let suffixes: Set<String> = ["plist", "savedstate", "binarycookies", "json", "log", "db", "sqlite", "sqlite3"]
    private static let minimumParts = 2

    static func name(_ name: String, belongsTo app: AppIdentity, in folder: SearchFolder, otherInstalledBundleIDs: Set<String>) -> Bool {
        let lowercased = name.lowercased()
        guard folder != .home, folder != .crashReporter, !app.isApple, !lowercased.hasPrefix("com.apple.") else { return false }
        var parts = lowercased.split(separator: ".").map(String.init)
        if let last = parts.last, suffixes.contains(last) { parts.removeLast() }
        guard parts.count >= minimumParts, let lastPart = parts.last else { return false }
        guard app.allNames.contains(where: { squashed($0) == squashed(lastPart) }) else { return false }
        let id = parts.joined(separator: ".")
        return !otherInstalledBundleIDs.contains { bundleID in
            let bundleID = bundleID.lowercased()
            return bundleID != app.bundleID.lowercased() && (id == bundleID || id.hasPrefix(bundleID + "."))
        }
    }

    private static func squashed(_ name: String) -> String {
        name.lowercased().filter { !$0.isWhitespace }
    }
}
