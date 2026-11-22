import Foundation

/// Answers sums, unit conversions and currency conversions, and sums that mix all three. A plain number on its own is not an answer, and a unit or currency amount on its own goes to its default target. A sum is labelled by its operators, a lone conversion by what it converts from, and the answer by its unit or currency, or by its spelled-out number when it is small and whole.
public enum Calculator {
    private static let largestSpelledOutNumber = 999.0

    public static func answer(for query: String, rates: CurrencyRates? = nil, locale: Locale = .current) -> Answer? {
        guard let parsed = ParsedQuery(query, rates: rates), let finished = finished(parsed.result, by: parsed.parser, rates: rates, locale: locale), finished.amount.isFinite else { return nil }
        let result = Quantity(finished.amount == 0 ? 0 : finished.amount, in: finished.measure)
        let parser = parsed.parser
        return Answer(
            input: parsed.text,
            inputLabel: parser.operators.isEmpty ? parser.sourceMeasure?.label(locale: locale) ?? "" : inputLabel(for: parser.operators),
            output: QuantityFormat.text(of: result, locale: locale),
            outputLabel: result.measure?.label(locale: locale) ?? outputLabel(for: result.amount, locale: locale),
            copyText: QuantityFormat.copyText(of: result, locale: locale)
        )
    }

    private static func finished(_ quantity: Quantity, by parser: ExpressionParser, rates: CurrencyRates?, locale: Locale) -> Quantity? {
        guard let measure = quantity.measure else { return parser.operators.isEmpty ? nil : quantity }
        guard parser.operators.isEmpty, !parser.hasConversion else { return quantity }
        guard let target = measure.defaultTarget(locale: locale) else { return nil }
        return quantity.converted(to: target, rates: rates)
    }

    private static func inputLabel(for operators: Set<ExpressionToken>) -> String {
        switch operators {
        case [.plus]: "Sum"
        case [.minus]: "Difference"
        case [.times]: "Product"
        case [.divide]: "Quotient"
        case [.power]: "Power"
        default: "Expression"
        }
    }

    private static func outputLabel(for value: Double, locale: Locale) -> String {
        guard value >= 0, value <= largestSpelledOutNumber, value.rounded() == value else { return "Result" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = locale
        guard let words = formatter.string(from: NSNumber(value: value)) else { return "Result" }
        return words.capitalisingFirstLetter
    }
}
