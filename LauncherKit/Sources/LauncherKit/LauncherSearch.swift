import Foundation

public enum LauncherSearch {
    public static func results(for query: String, in apps: [InstalledApp], launchCounts: LaunchCounts, locale: Locale = .current) -> [SearchResult] {
        let answers = [Calculator.answer(for: query, locale: locale)].compactMap { $0 }
        let matchingApps = AppRanking.matches(for: query, in: apps, launchCounts: launchCounts)
        return answers.map(SearchResult.answer) + matchingApps.map(SearchResult.app)
    }
}
