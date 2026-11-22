import Foundation

/// What an amount is counted in: a unit such as kilometres, or a currency named by its ISO code. Two units are the same when they have the same label, because every unit in the catalogue has a label of its own. A name that is both a unit and a currency code, such as `cup`, is read as the unit.
enum Measure: Equatable {
    case unit(UnitEntry)
    case currency(String)

    init?(named name: String) {
        if let entry = UnitCatalog.entry(named: name) {
            self = .unit(entry)
        } else if let code = CurrencyNames.code(for: name) {
            self = .currency(code)
        } else {
            return nil
        }
    }

    static func == (lhs: Measure, rhs: Measure) -> Bool {
        switch (lhs, rhs) {
        case (.unit(let left), .unit(let right)): left.label == right.label
        case (.currency(let left), .currency(let right)): left == right
        default: false
        }
    }

    func label(locale: Locale) -> String {
        switch self {
        case .unit(let entry): entry.label
        case .currency(let code): locale.localizedString(forCurrencyCode: code) ?? code
        }
    }

    /// Where an amount goes when the query names nothing to convert it into: each unit's usual partner, or the Mac's own currency. Money already in the Mac's own currency has nowhere to go.
    func defaultTarget(locale: Locale) -> Measure? {
        switch self {
        case .unit(let entry):
            return Measure(named: entry.defaultTarget)
        case .currency(let code):
            guard let local = locale.currency?.identifier, local != code else { return nil }
            return .currency(local)
        }
    }

    func measuresTheSameAs(_ other: Measure) -> Bool {
        switch (self, other) {
        case (.unit(let left), .unit(let right)): left.measuresTheSameAs(right)
        case (.currency, .currency): true
        default: false
        }
    }
}
