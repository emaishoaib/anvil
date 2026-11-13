import Foundation

enum LaunchCounts {
    private static let key = "launcher.launchCounts"

    static var all: [String: Int] {
        UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:]
    }

    static func record(_ app: InstalledApp) {
        var counts = all
        counts[app.url.path, default: 0] += 1
        UserDefaults.standard.set(counts, forKey: key)
    }
}
