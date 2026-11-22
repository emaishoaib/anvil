import Foundation

/// Works out a sum whose numbers can carry units and currencies. A unit or currency follows its number, and a currency can come before it too, as in `$100`. A conversion such as `to EGP` changes everything before it, or everything inside its brackets, and the word before the target can be left out. Unit and currency names are matched longest first, up to three words, so `fl oz` and `degrees celsius` are read whole and `in` is only read as "convert into" when it is not straight after a number.
struct ExpressionParser {
    private static let connectors: Set<String> = ["to", "in", "as", "into", "="]
    private static let longestNameWords = 3

    private let tokens: [ExpressionToken]
    private let rates: CurrencyRates?
    private var position = 0
    private(set) var operators: Set<ExpressionToken> = []
    private(set) var sourceMeasure: Measure?
    private(set) var hasConversion = false
    private(set) var unconverted: Quantity?

    init(tokens: [ExpressionToken], rates: CurrencyRates? = nil) {
        self.tokens = tokens
        self.rates = rates
    }

    mutating func parse() -> Quantity? {
        guard let value = expression() else { return nil }
        unconverted = value
        guard let converted = applyingConversions(to: value), position == tokens.count else { return nil }
        return converted
    }

    private var next: ExpressionToken? {
        tokens.indices.contains(position) ? tokens[position] : nil
    }

    private mutating func conversion() -> Quantity? {
        guard let value = expression() else { return nil }
        return applyingConversions(to: value)
    }

    private mutating func applyingConversions(to quantity: Quantity) -> Quantity? {
        var value = quantity
        while value.measure != nil, let target = target() {
            guard let converted = value.converted(to: target, rates: rates) else { return nil }
            value = converted
            hasConversion = true
        }
        return value
    }

    private mutating func target() -> Measure? {
        let start = position
        if case .word(let word) = next, Self.connectors.contains(word) { position += 1 }
        guard let measure = measure() else {
            position = start
            return nil
        }
        return measure
    }

    private mutating func expression() -> Quantity? {
        guard var value = term() else { return nil }
        while let token = next, token == .plus || token == .minus {
            position += 1
            guard let right = term(), let combined = value.combined(with: right, by: token, rates: rates) else { return nil }
            value = combined
            operators.insert(token)
        }
        return value
    }

    private mutating func term() -> Quantity? {
        guard var value = factor() else { return nil }
        while let token = next, token == .times || token == .divide {
            position += 1
            guard let right = factor(), let combined = value.combined(with: right, by: token, rates: rates) else { return nil }
            value = combined
            operators.insert(token)
        }
        return value
    }

    private mutating func factor() -> Quantity? {
        switch next {
        case .minus:
            position += 1
            return factor().map { Quantity(-$0.amount, in: $0.measure) }
        case .plus:
            position += 1
            return factor()
        default:
            return power()
        }
    }

    private mutating func power() -> Quantity? {
        guard let base = primary() else { return nil }
        guard next == .power else { return base }
        position += 1
        guard let exponent = factor(), let raised = base.combined(with: exponent, by: .power, rates: rates) else { return nil }
        operators.insert(.power)
        return raised
    }

    private mutating func primary() -> Quantity? {
        switch next {
        case .number(let amount):
            position += 1
            return noted(amount, in: measure())
        case .word:
            return amountAfterCurrency()
        case .open:
            position += 1
            guard let value = conversion(), next == .close else { return nil }
            position += 1
            return value
        default:
            return nil
        }
    }

    private mutating func amountAfterCurrency() -> Quantity? {
        let start = position
        guard let currency = measure(), case .currency = currency, case .number(let amount) = next else {
            position = start
            return nil
        }
        position += 1
        return noted(amount, in: currency)
    }

    private mutating func noted(_ amount: Double, in measure: Measure?) -> Quantity {
        if sourceMeasure == nil { sourceMeasure = measure }
        return Quantity(amount, in: measure)
    }

    private mutating func measure() -> Measure? {
        for count in stride(from: Self.longestNameWords, through: 1, by: -1) {
            guard let name = name(ofLength: count), let measure = Measure(named: name) else { continue }
            position += count
            return measure
        }
        return nil
    }

    private func name(ofLength count: Int) -> String? {
        guard position + count <= tokens.count else { return nil }
        var words: [String] = []
        for token in tokens[position..<position + count] {
            guard case .word(let word) = token else { return nil }
            words.append(word)
        }
        return words.joined(separator: " ")
    }
}
