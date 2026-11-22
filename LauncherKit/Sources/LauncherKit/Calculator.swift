import Foundation

public enum Calculator {
    private static let maximumFractionDigits = 10
    private static let largestSpelledOutNumber = 999.0

    public static func answer(for query: String, locale: Locale = .current) -> Answer? {
        var text = query.trimmingCharacters(in: .whitespaces)
        if text.hasSuffix("=") { text.removeLast() }
        guard let tokens = ExpressionToken.tokens(in: text) else { return nil }
        var parser = ExpressionParser(tokens: tokens)
        guard let quantity = parser.parse(), quantity.measure == nil, !parser.operators.isEmpty, quantity.amount.isFinite else { return nil }
        let result = quantity.amount == 0 ? 0 : quantity.amount
        let style = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0...maximumFractionDigits)).locale(locale)
        return Answer(
            input: text.trimmingCharacters(in: .whitespaces),
            inputLabel: inputLabel(for: parser.operators),
            output: result.formatted(style),
            outputLabel: outputLabel(for: result, locale: locale),
            copyText: result.formatted(style.grouping(.never))
        )
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
