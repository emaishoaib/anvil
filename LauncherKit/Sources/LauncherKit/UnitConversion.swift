import Foundation

public enum UnitConversion {
    private static let connectors: Set<String> = ["to", "in", "as", "into", "="]
    private static let longestNameWords = 3
    private static let maximumFractionDigits = 10

    public static func answer(for query: String, locale: Locale = .current) -> Answer? {
        var words = words(in: query)
        guard let first = words.first, let amount = Double(first) else { return nil }
        words.removeFirst()
        guard let (source, used) = leadingUnit(in: words) else { return nil }
        words.removeFirst(used)
        if let first = words.first, connectors.contains(first) { words.removeFirst() }
        let targetName = words.isEmpty ? source.defaultTarget : words.joined(separator: " ")
        guard let target = UnitCatalog.entry(named: targetName), target.measuresTheSameAs(source) else { return nil }
        let converted = source.convert(amount, to: target)
        guard converted.isFinite else { return nil }
        let value = converted == 0 ? 0 : converted
        let style = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0...maximumFractionDigits)).locale(locale)
        return Answer(
            input: query.trimmingCharacters(in: .whitespaces),
            inputLabel: source.label,
            output: "\(value.formatted(style)) \(target.display(value))",
            outputLabel: target.label,
            copyText: value.formatted(style.grouping(.never))
        )
    }

    private static func leadingUnit(in words: [String]) -> (UnitEntry, Int)? {
        for count in stride(from: min(longestNameWords, words.count), through: 1, by: -1) {
            if let entry = UnitCatalog.entry(named: words.prefix(count).joined(separator: " ")) { return (entry, count) }
        }
        return nil
    }

    private static func words(in query: String) -> [String] {
        query.lowercased()
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: #"(\d)([a-z°])"#, with: "$1 $2", options: .regularExpression)
            .split(separator: " ")
            .map(String.init)
    }
}
