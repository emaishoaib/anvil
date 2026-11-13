import Foundation

public enum LauncherSearch {
    private static let suggestionLimit = 8

    public static func results(
        for query: String,
        in apps: [InstalledApp],
        quickLinks: [QuickLink] = [],
        launchCounts: LaunchCounts,
        rates: CurrencyRates? = nil,
        now: Date = .now,
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> [SearchResult] {
        let answers = [
            Calculator.answer(for: query, locale: locale),
            DatePhrases.answer(for: query, now: now, calendar: calendar, locale: locale),
            UnitConversion.answer(for: query, locale: locale),
            rates.flatMap { CurrencyConversion.answer(for: query, rates: $0, locale: locale) },
        ].compactMap { $0 }
        let candidates = apps.map(SearchResult.app) + LauncherCommand.allCases.map(SearchResult.command) + quickLinks.map(SearchResult.quickLink)
        let ranked = query.trimmingCharacters(in: .whitespaces).isEmpty
            ? ResultRanking.suggestions(in: candidates, launchCounts: launchCounts, limit: suggestionLimit)
            : ResultRanking.matches(for: query, in: candidates, launchCounts: launchCounts)
        return answers.map(SearchResult.answer) + ranked
    }
}
