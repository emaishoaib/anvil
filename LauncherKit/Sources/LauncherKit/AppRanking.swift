import Foundation

public enum AppRanking {
    public static func matches(for query: String, in apps: [InstalledApp], launchCounts: LaunchCounts) -> [InstalledApp] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        return apps
            .compactMap { app in app.match(for: query).map { (app: app, match: $0, launches: launchCounts.count(for: app)) } }
            .sorted { (-$0.launches, $0.match.rawValue, $0.app.name.localizedLowercase) < (-$1.launches, $1.match.rawValue, $1.app.name.localizedLowercase) }
            .map(\.app)
    }
}
