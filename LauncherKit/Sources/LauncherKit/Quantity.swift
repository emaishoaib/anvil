import Foundation

/// A number that can carry a unit or a currency, so a sum can mix plain numbers, units and money. A plain number takes on the measure of whatever it meets, and two amounts of the same kind are worked out in the left one's measure. Amounts of different kinds never combine, and changing between currencies needs the day's rates.
struct Quantity: Equatable {
    let amount: Double
    let measure: Measure?

    init(_ amount: Double, in measure: Measure? = nil) {
        self.amount = amount
        self.measure = measure
    }

    func converted(to target: Measure, rates: CurrencyRates?) -> Quantity? {
        guard let measure else { return nil }
        guard measure != target else { return self }
        switch (measure, target) {
        case (.unit(let source), .unit(let destination)):
            guard source.measuresTheSameAs(destination) else { return nil }
            let converted = source.convert(amount, to: destination)
            return converted.isFinite ? Quantity(converted, in: target) : nil
        case (.currency(let source), .currency(let destination)):
            return rates?.convert(amount, from: source, to: destination).map { Quantity($0, in: target) }
        default:
            return nil
        }
    }

    func combined(with other: Quantity, by operation: ExpressionToken, rates: CurrencyRates?) -> Quantity? {
        switch operation {
        case .plus, .minus:
            guard let (left, right) = matched(with: other, rates: rates) else { return nil }
            let amount = operation == .plus ? left.amount + right.amount : left.amount - right.amount
            return Quantity(amount, in: left.measure)
        case .times:
            guard measure == nil || other.measure == nil else { return nil }
            return Quantity(amount * other.amount, in: measure ?? other.measure)
        case .divide:
            guard other.measure != nil else { return Quantity(amount / other.amount, in: measure) }
            guard let measure, let divisor = other.converted(to: measure, rates: rates) else { return nil }
            return Quantity(amount / divisor.amount)
        case .power:
            guard measure == nil, other.measure == nil else { return nil }
            return Quantity(pow(amount, other.amount))
        default:
            return nil
        }
    }

    private func matched(with other: Quantity, rates: CurrencyRates?) -> (Quantity, Quantity)? {
        switch (measure, other.measure) {
        case (nil, nil):
            return (self, other)
        case (let measure?, nil):
            return (self, Quantity(other.amount, in: measure))
        case (nil, let measure?):
            return (Quantity(amount, in: measure), other)
        case (let measure?, .some):
            guard let right = other.converted(to: measure, rates: rates) else { return nil }
            return (self, right)
        }
    }
}
