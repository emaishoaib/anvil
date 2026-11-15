import Foundation

/// The bundle IDs of the helper apps, extensions and background services an app carries inside itself, such as an updater or a browser helper. These helpers keep files in the Library under their own bundle IDs, so those files belong to the app too.
///
/// Helpers can sit anywhere inside the app, even deep inside a framework, so the whole app is looked through. Bundle IDs come back in lowercase. Apple's own apps are given no helpers, because their helpers are shared across the system. Two kinds of helper are left out:
/// - a helper from another vendor, such as the Sparkle updater many apps carry, because other apps keep files under the same bundle ID
/// - a helper that another installed app from the same vendor also carries, or that is that app itself, because its files may belong to that app
enum HelperBundleIDs {
    private static let bundleExtensions: Set<String> = ["app", "appex", "xpc"]

    static func of(_ app: AppIdentity, at appURL: URL, otherAppURLs: [URL]) -> Set<String> {
        guard !app.isApple, let vendor = app.vendor else { return [] }
        let ownHelpers = bundleIDs(inAppAt: appURL).filter { bundleID in
            bundleID != app.bundleID.lowercased() && AppIdentity.vendor(of: bundleID) == vendor
        }
        guard !ownHelpers.isEmpty else { return [] }
        let sameVendorApps = otherAppURLs.filter { AppIdentity(appAt: $0)?.vendor == vendor }
        let shared = sameVendorApps.reduce(into: Set<String>()) { $0.formUnion(bundleIDs(inAppAt: $1)) }
        return ownHelpers.subtracting(shared)
    }

    /// The bundle ID of the app itself and of every bundle inside it.
    private static func bundleIDs(inAppAt appURL: URL) -> Set<String> {
        let contents = appURL.appending(path: "Contents", directoryHint: .isDirectory)
        let nested = FileManager.default.enumerator(at: contents, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { bundleExtensions.contains($0.pathExtension.lowercased()) } ?? []
        return Set(([appURL] + nested).compactMap { Bundle(url: $0)?.bundleIdentifier?.lowercased() })
    }
}
