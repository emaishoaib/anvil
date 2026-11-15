import Foundation

/// The app whose leftovers are searched for: its bundle ID, the name Finder shows for it, the other names it goes by, the bundle IDs of the helpers it carries inside itself, and the app groups it shares files through. Lone app groups are the ones only a single bundle inside the app lists, so they may be shared with a program outside it.
public struct AppIdentity: Hashable, Sendable {
    public let bundleID: String
    public let name: String
    public let otherNames: Set<String>
    public let helperBundleIDs: Set<String>
    public let appGroups: Set<String>
    public let loneAppGroups: Set<String>

    public init(bundleID: String, name: String, otherNames: Set<String> = [], helperBundleIDs: Set<String> = [], appGroups: Set<String> = [], loneAppGroups: Set<String> = []) {
        self.bundleID = bundleID
        self.name = name
        self.otherNames = otherNames
        self.helperBundleIDs = helperBundleIDs
        self.appGroups = appGroups
        self.loneAppGroups = loneAppGroups
    }

    /// Reads the bundle ID from the app's Info.plist and takes the name from its file name. The other names are the bundle name, the display name and the executable's name from the Info.plist, and the file name without a version number at the end, such as `Tinderbox` for `Tinderbox 11`. An app without a bundle ID gives nothing. Helpers and app groups are not read here, because finding them means looking through the whole app.
    public init?(appAt url: URL) {
        guard let bundle = Bundle(url: url), let bundleID = bundle.bundleIdentifier else { return nil }
        let name = url.deletingPathExtension().lastPathComponent
        let infoNames = Self.infoNameKeys.compactMap { bundle.object(forInfoDictionaryKey: $0) as? String }
        self.init(bundleID: bundleID, name: name, otherNames: Self.names(infoNames + [Self.withoutVersion(name)], besides: name))
    }

    func with(otherNames: Set<String>, helperBundleIDs: Set<String>, appGroups: AppGroups) -> AppIdentity {
        AppIdentity(bundleID: bundleID, name: name, otherNames: otherNames, helperBundleIDs: helperBundleIDs, appGroups: appGroups.sharedWithinApp, loneAppGroups: appGroups.lone)
    }

    /// The app's name followed by its other names.
    var allNames: [String] { [name] + otherNames.sorted() }

    /// The names worth keeping from a list: at least three letters or digits long, and not the app's own name again.
    static func names(_ candidates: [String], besides name: String) -> Set<String> {
        Set(candidates.filter { candidate in
            candidate.lowercased() != name.lowercased() && candidate.filter { $0.isLetter || $0.isNumber }.count >= minimumNameLength
        })
    }

    private static let infoNameKeys = ["CFBundleName", "CFBundleDisplayName", "CFBundleExecutable"]
    private static let minimumNameLength = 3

    private static func withoutVersion(_ name: String) -> String {
        name.replacing(/\s*\d+(\.\d+)*$/, with: "")
    }

    /// The bundle IDs and app groups the Library may name the app's files after, leaving out the lone app groups.
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
