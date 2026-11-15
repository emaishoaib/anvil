import Foundation
import Synchronization

/// Finds, in one walk through the given folders, the files and folders named after each of the given apps, under the rule in `WalkMatch`. The folders are walked side by side on several threads, as `DiskWalk` does.
///
/// The walk stops at the first name on a path that belongs to any of the apps, and does not look inside it. So a folder named after an app is found as a whole rather than file by file, and a name found inside another app's folder, such as App Cleaner's own record of Raycast, is left to that app. A name that belongs to several apps goes to the ones whose words run longest in it, as `AppWordIndex` decides.
enum WalkSearch {
    static func matches(of apps: [AppIdentity], in folders: [URL]) -> [AppIdentity: [URL]] {
        let index = AppWordIndex(apps: apps)
        let found = Mutex<[AppIdentity: [URL]]>([:])
        DiskWalk.walkSideBySide(folders) { item in
            let owners = index.owners(of: item.name)
            guard !owners.isEmpty else { return .goInside }
            let url = item.url
            found.withLock { found in
                for app in owners {
                    found[app, default: []].append(url)
                }
            }
            return .stayOutside
        }
        return found.withLock { $0 }
    }
}
