import Foundation

/// A query read as a sum, with a trailing equals sign dropped, so the answer and anything shown beside it read the query the same way.
struct ParsedQuery {
    let text: String
    let parser: ExpressionParser
    let result: Quantity

    init?(_ query: String, rates: CurrencyRates?) {
        var text = query.trimmingCharacters(in: .whitespaces)
        if text.hasSuffix("=") { text.removeLast() }
        guard let tokens = ExpressionToken.tokens(in: text) else { return nil }
        var parser = ExpressionParser(tokens: tokens, rates: rates)
        guard let result = parser.parse() else { return nil }
        self.text = text.trimmingCharacters(in: .whitespaces)
        self.parser = parser
        self.result = result
    }
}
