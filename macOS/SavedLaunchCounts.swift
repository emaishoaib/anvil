import Foundation
import LauncherKit

enum SavedLaunchCounts {
    private static let key = "launcher.launchCounts"

    static func load() -> LaunchCounts {
        LaunchCounts(UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:])
    }

    static func record(_ app: InstalledApp) {
        var counts = load()
        counts.record(app)
        UserDefaults.standard.set(counts.byPath, forKey: key)
    }
}
