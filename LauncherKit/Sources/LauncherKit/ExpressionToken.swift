enum ExpressionToken: Hashable {
    case number(Double)
    case plus, minus, times, divide, power, open, close

    static func tokens(in text: String) -> [ExpressionToken]? {
        var tokens: [ExpressionToken] = []
        var digits = ""

        func flushDigits() -> Bool {
            guard !digits.isEmpty else { return true }
            guard let value = Double(digits) else { return false }
            tokens.append(.number(value))
            digits = ""
            return true
        }

        for character in text {
            if (character.isASCII && character.isNumber) || character == "." {
                digits.append(character)
                continue
            }
            guard flushDigits() else { return nil }
            switch character {
            case " ": continue
            case "+": tokens.append(.plus)
            case "-", "−": tokens.append(.minus)
            case "*", "×", "x", "X": tokens.append(.times)
            case "/", "÷": tokens.append(.divide)
            case "^": tokens.append(.power)
            case "(": tokens.append(.open)
            case ")": tokens.append(.close)
            default: return nil
            }
        }
        guard flushDigits() else { return nil }
        return tokens
    }
}
