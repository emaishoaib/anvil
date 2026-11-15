/// Whether a name in one of the search folders belongs to an app because it is named after the app or its vendor, such as `Spotify` in Application Support. Any of the app's names counts, so Visual Studio Code also finds `Code`.
///
/// Only the folders where apps make folders under plain names are checked this way. Names are compared ignoring letter case and spaces, so an app called `Visual Notes` also finds `VisualNotes`. In the home folder the name may also start with a dot, as in `.docker`, because apps often hide their folders there, and a hidden folder there may also be named after the last part of the bundle ID, as in `.vscode` for `com.microsoft.VSCode`, unless that part is a generic word such as `mac` or `app`. In the folders where apps also keep loose files, such as Logs and Preferences, a file named after the app with a file extension counts too, such as `Folx.log`.
///
/// Four rules keep this from catching another app's files or the user's own:
/// - Apple's own apps are never matched this way, and no name starting with `com.apple.` ever is
/// - a vendor's folder only belongs to the app when no other installed app comes from the same vendor, because the folder may hold that app's files too
/// - a bundle ID with fewer than three parts has no vendor to match
/// - in the home folder only the app's file name counts, not its other names or its vendor, and the folders macOS makes there, such as Documents and Downloads, never match
/// - in `~/Library` itself the folders macOS makes there, such as Fonts and Keychains, never match
enum NameMatch {
    private static let standardHomeFolders: Set<String> = ["applications", "desktop", "documents", "downloads", "library", "movies", "music", "pictures", "public"]
    private static let standardLibraryFolders: Set<String> = [
        "accounts", "application scripts", "application support", "assistants", "audio", "autosave information", "caches", "calendars",
        "colorpickers", "colors", "compositions", "containers", "cookies", "developer", "dictionaries", "favorites", "fontcollections", "fonts",
        "group containers", "httpstorages", "input methods", "internet plug-ins", "keyboard layouts", "keychains", "launchagents", "logs", "mail",
        "messages", "metadata", "mobile documents", "passes", "photos", "preferencepanes", "preferences", "printers", "quicklook", "safari",
        "saved application state", "screen savers", "scripts", "services", "sharing", "shortcuts", "sounds", "spelling", "spotlight",
        "suggestions", "translation", "webkit",
    ]

    private static let maximumExtensionLength = 8
    private static let genericBundleIDEndings: Set<String> = ["app", "application", "client", "desktop", "main", "mac", "macos", "osx"]
    private static let minimumBundleIDEndingLength = 3

    static func name(_ name: String, belongsTo app: AppIdentity, in folder: SearchFolder, otherInstalledBundleIDs: Set<String>) -> Bool {
        guard !app.isApple, !name.lowercased().hasPrefix("com.apple.") else { return false }
        if folder.holdsFilesNamedAfterApps, let baseName = withoutExtension(name), app.allNames.contains(where: { squashed($0) == squashed(baseName) }) { return true }
        guard folder.holdsFoldersNamedAfterApps else { return false }
        guard !standardFolders(in: folder).contains(name.lowercased()) else { return false }
        let squashedName = squashed(name)
        let squashedAppName = squashed(app.name)
        guard folder != .home else {
            let hiddenNames = ["." + squashedAppName, bundleIDEnding(of: app).map { "." + $0 }].compactMap { $0 }
            return squashedName == squashedAppName || hiddenNames.contains(squashedName)
        }
        let isNamedAfterApp = app.allNames.contains { squashed($0) == squashedName }
        guard folder.holdsFoldersNamedAfterVendors else { return isNamedAfterApp }
        let isNamedAfterVendor = app.vendor.map { vendor in
            squashedName == vendor && !isShared(vendor, by: otherInstalledBundleIDs, besides: app)
        } ?? false
        return isNamedAfterApp || isNamedAfterVendor
    }

    private static func standardFolders(in folder: SearchFolder) -> Set<String> {
        switch folder {
        case .home: standardHomeFolders
        case .library: standardLibraryFolders
        default: []
        }
    }

    private static func isShared(_ vendor: String, by bundleIDs: Set<String>, besides app: AppIdentity) -> Bool {
        bundleIDs.contains { bundleID in
            bundleID.lowercased() != app.bundleID.lowercased() && AppIdentity.vendor(of: bundleID) == vendor
        }
    }

    /// The last part of the app's bundle ID in lowercase, such as `vscode` for `com.microsoft.VSCode`, or nothing when it is shorter than three letters or a generic word such as `mac`.
    private static func bundleIDEnding(of app: AppIdentity) -> String? {
        guard let ending = app.bundleID.lowercased().split(separator: ".").last.map(String.init),
              ending.count >= minimumBundleIDEndingLength, !genericBundleIDEndings.contains(ending)
        else { return nil }
        return squashed(ending)
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
