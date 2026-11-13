import Foundation

struct ExpressionParser {
    private let tokens: [ExpressionToken]
    private var position = 0
    private(set) var operators: Set<ExpressionToken> = []

    init(tokens: [ExpressionToken]) {
        self.tokens = tokens
    }

    mutating func parse() -> Double? {
        guard let value = expression(), position == tokens.count else { return nil }
        return value
    }

    private var next: ExpressionToken? {
        tokens.indices.contains(position) ? tokens[position] : nil
    }

    private mutating func expression() -> Double? {
        guard var value = term() else { return nil }
        while let token = next, token == .plus || token == .minus {
            position += 1
            guard let right = term() else { return nil }
            value = token == .plus ? value + right : value - right
            operators.insert(token)
        }
        return value
    }

    private mutating func term() -> Double? {
        guard var value = factor() else { return nil }
        while let token = next, token == .times || token == .divide {
            position += 1
            guard let right = factor() else { return nil }
            value = token == .times ? value * right : value / right
            operators.insert(token)
        }
        return value
    }

    private mutating func factor() -> Double? {
        switch next {
        case .minus:
            position += 1
            return factor().map { -$0 }
        case .plus:
            position += 1
            return factor()
        default:
            return power()
        }
    }

    private mutating func power() -> Double? {
        guard let base = primary() else { return nil }
        guard next == .power else { return base }
        position += 1
        guard let exponent = factor() else { return nil }
        operators.insert(.power)
        return pow(base, exponent)
    }

    private mutating func primary() -> Double? {
        switch next {
        case .number(let value):
            position += 1
            return value
        case .open:
            position += 1
            guard let value = expression(), next == .close else { return nil }
            position += 1
            return value
        default:
            return nil
        }
    }
}
