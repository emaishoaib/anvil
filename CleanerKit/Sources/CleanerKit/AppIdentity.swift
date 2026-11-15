import Foundation

/// The app whose leftovers are searched for: its bundle ID, the name Finder shows for it, the bundle IDs of the helpers it carries inside itself, and the app groups it shares files through.
public struct AppIdentity: Hashable, Sendable {
    public let bundleID: String
    public let name: String
    public let helperBundleIDs: Set<String>
    public let appGroups: Set<String>

    public init(bundleID: String, name: String, helperBundleIDs: Set<String> = [], appGroups: Set<String> = []) {
        self.bundleID = bundleID
        self.name = name
        self.helperBundleIDs = helperBundleIDs
        self.appGroups = appGroups
    }

    /// Reads the bundle ID from the app's Info.plist and takes the name from its file name. An app without a bundle ID gives nothing. Helpers and app groups are not read here, because finding them means looking through the whole app.
    public init?(appAt url: URL) {
        guard let bundleID = Bundle(url: url)?.bundleIdentifier else { return nil }
        self.init(bundleID: bundleID, name: url.deletingPathExtension().lastPathComponent)
    }

    /// The bundle IDs and app groups the Library may name the app's files after.
    var identifiers: Set<String> { helperBundleIDs.union(appGroups).union([bundleID]) }

    var isApple: Bool { bundleID.lowercased().hasPrefix("com.apple.") }

    var vendor: String? { Self.vendor(of: bundleID) }

    /// The vendor part of a reverse-domain bundle ID, such as `spotify` in `com.spotify.client`. A bundle ID with fewer than three parts has no vendor, because its second part may be the app itself.
    static func vendor(of bundleID: String) -> String? {
        let parts = bundleID.lowercased().split(separator: ".")
        guard parts.count >= 3 else { return nil }
        return String(parts[1])
    }
}
