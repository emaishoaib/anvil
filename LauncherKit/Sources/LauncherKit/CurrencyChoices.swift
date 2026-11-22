import Foundation

/// Which currencies the currency table lists. It starts with the world's most traded currencies and the Mac's own when it is not one of them, and any other currency with a rate can be found by its code or its name to add. Codes match before names, and matches that start a word come before ones inside it.
public enum CurrencyChoices {
    private static let topCodes = ["USD", "EUR", "JPY", "GBP", "CNY", "AUD", "CAD", "CHF", "HKD", "SGD"]
    private static let isoCodes = Set(Locale.Currency.isoCurrencies.map(\.identifier))

    public static func startingCodes(locale: Locale = .current) -> [String] {
        guard let local = locale.currency?.identifier, !topCodes.contains(local) else { return topCodes }
        return topCodes + [local]
    }

    public static func matching(_ query: String, rates: CurrencyRates, locale: Locale = .current) -> [Currency] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        return rates.perDollar.keys
            .filter(isoCodes.contains)
            .map { Currency(code: $0, locale: locale) }
            .compactMap { currency in rank(of: currency, for: query).map { (currency: currency, rank: $0) } }
            .sorted { ($0.rank, $0.currency.name.localizedLowercase) < ($1.rank, $1.currency.name.localizedLowercase) }
            .map(\.currency)
    }

    private static func rank(of currency: Currency, for query: String) -> Int? {
        if NameMatch(name: currency.code, query: query) == .namePrefix { return 0 }
        return NameMatch(name: currency.name, query: query).map { 1 + $0.rawValue }
    }
}
