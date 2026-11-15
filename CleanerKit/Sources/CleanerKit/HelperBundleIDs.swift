import Foundation

/// The bundle IDs of the helper apps, extensions and background services an app carries inside itself, such as an updater or a browser helper. These helpers keep files in the Library under their own bundle IDs, so those files belong to the app too.
///
/// A helper belongs to the app when it comes from the app's vendor, or when its bundle ID starts with the app's team ID, such as `2BUA8C4S2C.com.1password.browser-helper`. Bundle IDs come back in lowercase. Two kinds of helper are left out:
/// - a helper from another vendor, such as the Sparkle updater many apps carry, because other apps keep files under the same bundle ID
/// - a helper that another installed app from the same vendor also carries, or that is that app itself, because its files may belong to that app
enum HelperBundleIDs {
    static func of(_ app: AppIdentity, nestedBundles: [URL], teamID: String?, otherAppURLs: [URL]) -> Set<String> {
        guard let vendor = app.vendor else { return [] }
        let teamPrefix = teamID.map { $0.lowercased() + "." }
        let ownHelpers = bundleIDs(of: nestedBundles).filter { bundleID in
            let isFromVendor = AppIdentity.vendor(of: bundleID) == vendor
            let isFromTeam = teamPrefix.map { bundleID.hasPrefix($0) } ?? false
            return bundleID != app.bundleID.lowercased() && (isFromVendor || isFromTeam)
        }
        guard !ownHelpers.isEmpty else { return [] }
        let sameVendorApps = otherAppURLs.filter { AppIdentity(appAt: $0)?.vendor == vendor }
        let shared = sameVendorApps.reduce(into: Set<String>()) { $0.formUnion(bundleIDs(of: [$1] + NestedBundles.urls(inAppAt: $1))) }
        return ownHelpers.subtracting(shared)
    }

    private static func bundleIDs(of bundles: [URL]) -> Set<String> {
        Set(bundles.compactMap { Bundle(url: $0)?.bundleIdentifier?.lowercased() })
    }
}
