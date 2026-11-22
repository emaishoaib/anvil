import Foundation

/// The ways a currency can be written in a query: its three-letter ISO code in any case, one of a few symbols, or a few everyday names.
enum CurrencyNames {
    static let symbols: Set<Character> = ["$", "€", "£", "¥", "₹", "₩", "₺"]

    private static let codesBySymbol = ["$": "USD", "€": "EUR", "£": "GBP", "¥": "JPY", "₹": "INR", "₩": "KRW", "₺": "TRY"]
    private static let codesByName = ["dollar": "USD", "dollars": "USD", "euro": "EUR", "euros": "EUR", "yen": "JPY", "rupee": "INR", "rupees": "INR"]
    private static let isoCodes = Set(Locale.Currency.isoCurrencies.map(\.identifier))
    private static let isoCodeLength = 3

    static func code(for word: String) -> String? {
        let lowered = word.lowercased()
        if let code = codesBySymbol[lowered] ?? codesByName[lowered] { return code }
        let code = word.uppercased()
        return word.count == isoCodeLength && isoCodes.contains(code) ? code : nil
    }
}
