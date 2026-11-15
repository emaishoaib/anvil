import Foundation

/// Finds, in one walk through the given folders, the files and folders named after each of the given apps, under the rule in `WalkMatch`.
///
/// The walk stops at the first name on a path that belongs to any of the apps, and does not look inside it. So a folder named after an app is found as a whole rather than file by file, and a name found inside another app's folder, such as App Cleaner's own record of Raycast, is left to that app. A name that belongs to several apps goes to the ones whose words run longest in it, as `AppWordIndex` decides.
enum WalkSearch {
    static func matches(of apps: [AppIdentity], in folders: [URL]) -> [AppIdentity: [URL]] {
        let index = AppWordIndex(apps: apps)
        var found: [AppIdentity: [URL]] = [:]
        DiskWalk.walk(folders) { item in
            let owners = index.owners(of: item.lastPathComponent)
            guard !owners.isEmpty else { return .goInside }
            for app in owners {
                found[app, default: []].append(item)
            }
            return .stayOutside
        }
        return found
    }
}
