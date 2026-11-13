import Foundation

public enum LauncherSearch {
    public static func results(
        for query: String,
        in apps: [InstalledApp],
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
        let candidates = apps.map(SearchResult.app) + LauncherCommand.allCases.map(SearchResult.command)
        return answers.map(SearchResult.answer) + ResultRanking.matches(for: query, in: candidates, launchCounts: launchCounts)
    }
}
