/// Whether a name in one of the search folders belongs to an app because it is named after the app or its vendor, such as `Spotify` in Application Support.
///
/// Only the folders where apps make folders under plain names are checked this way. Names are compared ignoring letter case and spaces, so an app called `Visual Notes` also finds `VisualNotes`.
///
/// Three rules keep this from catching another app's files:
/// - Apple's own apps are never matched this way, and no name starting with `com.apple.` ever is
/// - a vendor's folder only belongs to the app when no other installed app comes from the same vendor, because the folder may hold that app's files too
/// - a bundle ID with fewer than three parts has no vendor to match
enum NameMatch {
    static func name(_ name: String, belongsTo app: AppIdentity, in folder: SearchFolder, otherInstalledBundleIDs: Set<String>) -> Bool {
        guard folder.holdsFoldersNamedAfterApps, !app.isApple, !name.lowercased().hasPrefix("com.apple.") else { return false }
        let squashedName = squashed(name)
        let isNamedAfterApp = squashedName == squashed(app.name)
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

    private static func squashed(_ name: String) -> String {
        name.lowercased().filter { !$0.isWhitespace }
    }
}
