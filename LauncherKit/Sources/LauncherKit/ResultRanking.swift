import Foundation

public enum ResultRanking {
    public static func matches(for query: String, in candidates: [SearchResult], launchCounts: LaunchCounts) -> [SearchResult] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        return candidates
            .compactMap { result in
                result.match(for: query).map { (result: result, match: $0, launches: launchCounts.count(for: result.launchKey ?? "")) }
            }
            .sorted {
                (-$0.launches, $0.match.rawValue, $0.result.name.localizedLowercase) < (-$1.launches, $1.match.rawValue, $1.result.name.localizedLowercase)
            }
            .map(\.result)
    }
}
