import Foundation
import LauncherKit

enum SavedLaunchCounts {
    private static let key = "launcher.launchCounts"

    static func load() -> LaunchCounts {
        LaunchCounts(UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:])
    }

    static func reset(_ launchKey: String) {
        var counts = load()
        counts.reset(launchKey)
        UserDefaults.standard.set(counts.byKey, forKey: key)
    }

    static func record(_ launchKey: String) {
        var counts = load()
        counts.record(launchKey)
        UserDefaults.standard.set(counts.byKey, forKey: key)
    }
}
