import Foundation
import LauncherKit

enum SavedRecentWords {
    private static let key = "launcher.recentWords"

    static func load() -> RecentWords {
        RecentWords(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }

    static func record(_ word: String) {
        var recent = load()
        recent.record(word)
        UserDefaults.standard.set(recent.words, forKey: key)
    }
}
