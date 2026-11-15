import Foundation

/// The app whose leftovers are searched for: its bundle ID and the name Finder shows for it.
public struct AppIdentity: Hashable, Sendable {
    public let bundleID: String
    public let name: String

    public init(bundleID: String, name: String) {
        self.bundleID = bundleID
        self.name = name
    }

    /// Reads the bundle ID from the app's Info.plist and takes the name from its file name. An app without a bundle ID gives nothing.
    public init?(appAt url: URL) {
        guard let bundleID = Bundle(url: url)?.bundleIdentifier else { return nil }
        self.init(bundleID: bundleID, name: url.deletingPathExtension().lastPathComponent)
    }

    var isApple: Bool { bundleID.lowercased().hasPrefix("com.apple.") }

    var vendor: String? { Self.vendor(of: bundleID) }

    /// The vendor part of a reverse-domain bundle ID, such as `spotify` in `com.spotify.client`. A bundle ID with fewer than three parts has no vendor, because its second part may be the app itself.
    static func vendor(of bundleID: String) -> String? {
        let parts = bundleID.lowercased().split(separator: ".")
        guard parts.count >= 3 else { return nil }
        return String(parts[1])
    }
}
