/// Whether a name belongs to an app because it is the app's bundle ID with the last part dropped, such as `com.stairways.keyboardmaestro.plist` for Keyboard Maestro, whose bundle ID is `com.stairways.keyboardmaestro.editor`. Some apps keep their settings under the name of the whole product rather than the one program.
///
/// Three rules keep this tight:
/// - only the shorter ID itself, or the shorter ID followed by `.plist`, counts
/// - only a bundle ID with four or more parts is shortened, so what is left still names a product rather than a company, such as `com.stairways`
/// - the shorter ID only belongs to the app when no other installed app's bundle ID starts with it, because the file may be that app's too
///
/// Apple's own apps are never matched this way. Letter case is ignored.
enum ParentBundleIDMatch {
    private static let minimumParts = 4

    static func name(_ name: String, belongsTo app: AppIdentity, otherInstalledBundleIDs: Set<String>) -> Bool {
        let parts = app.bundleID.lowercased().split(separator: ".")
        guard !app.isApple, parts.count >= minimumParts else { return false }
        let parent = parts.dropLast().joined(separator: ".")
        let name = name.lowercased()
        guard name == parent || name == parent + ".plist" else { return false }
        return !otherInstalledBundleIDs.contains { bundleID in
            let bundleID = bundleID.lowercased()
            return bundleID != app.bundleID.lowercased() && (bundleID == parent || bundleID.hasPrefix(parent + "."))
        }
    }
}
