import Foundation

/// How a worked-out quantity reads in the bar and on the clipboard. Money is shown in its currency's own format, a unit amount is followed by its symbol, and a plain number stands alone with up to ten decimal places. What is copied is always a plain number without thousands separators.
enum QuantityFormat {
    private static let maximumFractionDigits = 10
    private static let currencyFractionDigits = 2

    static func text(of quantity: Quantity, locale: Locale) -> String {
        let style = numberStyle(locale: locale)
        return switch quantity.measure {
        case .currency(let code): quantity.amount.formatted(.currency(code: code).locale(locale))
        case .unit(let entry): "\(quantity.amount.formatted(style)) \(entry.display(quantity.amount))"
        case nil: quantity.amount.formatted(style)
        }
    }

    static func copyText(of quantity: Quantity, locale: Locale) -> String {
        switch quantity.measure {
        case .currency: quantity.amount.formatted(.number.precision(.fractionLength(currencyFractionDigits)).grouping(.never).locale(locale))
        case .unit, nil: quantity.amount.formatted(numberStyle(locale: locale).grouping(.never))
        }
    }

    private static func numberStyle(locale: Locale) -> FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0...maximumFractionDigits)).locale(locale)
    }
}
