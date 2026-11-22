import Foundation

public enum CurrencyConversion {
    private static let connectors: Set<String> = ["to", "in", "as", "into", "="]
    private static let symbolPattern = "[$€£¥₹₩₺]"

    public static func answer(for query: String, rates: CurrencyRates, locale: Locale = .current) -> Answer? {
        var words = words(in: query)
        var from: String?
        if words.count > 1, let code = currency(words[0]), Double(words[1]) != nil {
            from = code
            words.removeFirst()
        }
        guard let first = words.first, let amount = Double(first) else { return nil }
        words.removeFirst()
        if from == nil {
            guard let first = words.first, let code = currency(first) else { return nil }
            from = code
            words.removeFirst()
        }
        if let first = words.first, connectors.contains(first) { words.removeFirst() }
        guard let from, let to = target(of: words, from: from, locale: locale), let converted = rates.convert(amount, from: from, to: to) else { return nil }
        return Answer(
            input: query.trimmingCharacters(in: .whitespaces),
            inputLabel: locale.localizedString(forCurrencyCode: from) ?? from,
            output: converted.formatted(.currency(code: to).locale(locale)),
            outputLabel: locale.localizedString(forCurrencyCode: to) ?? to,
            copyText: converted.formatted(.number.precision(.fractionLength(2)).grouping(.never).locale(locale))
        )
    }

    private static func target(of words: [String], from: String, locale: Locale) -> String? {
        switch words.count {
        case 0:
            guard let local = locale.currency?.identifier, local != from else { return nil }
            return local
        case 1:
            return currency(words[0])
        default:
            return nil
        }
    }

    private static func currency(_ word: String) -> String? {
        CurrencyNames.code(for: word)
    }

    private static func words(in query: String) -> [String] {
        query.lowercased()
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: #"(\d)([a-z]|\#(symbolPattern))"#, with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: #"(\#(symbolPattern))(\d)"#, with: "$1 $2", options: .regularExpression)
            .split(separator: " ")
            .map(String.init)
    }
}
