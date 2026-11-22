import Foundation

/// An amount of money shown in the chosen currencies, in the order they were chosen. The amount is the query's money before any `to` at its end, so adding a target leaves the table as it was. The amount's own currency is left out, and so is any currency without a rate.
public struct CurrencyTable: Hashable, Sendable {
    public struct Row: Hashable, Sendable, Identifiable {
        public let code: String
        public let name: String
        public let amount: String
        public let copyText: String

        public var id: String {
            code
        }
    }

    public let rows: [Row]

    public init?(for query: String, codes: [String], rates: CurrencyRates?, locale: Locale = .current) {
        guard let parsed = ParsedQuery(query, rates: rates), let amount = parsed.parser.unconverted, case .currency(let source) = amount.measure,
              amount.amount.isFinite, case .currency? = parsed.result.measure
        else { return nil }
        let rows = codes.filter { $0 != source }.compactMap { code -> Row? in
            guard let converted = amount.converted(to: .currency(code), rates: rates) else { return nil }
            return Row(
                code: code,
                name: Measure.currency(code).label(locale: locale),
                amount: QuantityFormat.text(of: converted, locale: locale),
                copyText: QuantityFormat.copyText(of: converted, locale: locale)
            )
        }
        guard !rows.isEmpty else { return nil }
        self.rows = rows
    }
}
