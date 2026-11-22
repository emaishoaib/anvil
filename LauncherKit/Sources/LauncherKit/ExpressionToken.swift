enum ExpressionToken: Hashable {
    case number(Double)
    case word(String)
    case plus, minus, times, divide, power, open, close

    private static let timesLetter = "x"

    /// Splits a query into numbers, lowercased words and operators. Letters run together into a word, and a word carries on through digits and through a slash that leads to more letters, so `m2` and `km/h` stay whole. A word that is only `x` is the times sign, a comma inside a number separates thousands, and each currency symbol and the equals sign are words of their own.
    static func tokens(in text: String) -> [ExpressionToken]? {
        let characters = Array(text)
        var tokens: [ExpressionToken] = []
        var digits = ""
        var word = ""

        func flushWord() {
            guard !word.isEmpty else { return }
            let lowered = word.lowercased()
            tokens.append(lowered == timesLetter ? .times : .word(lowered))
            word = ""
        }

        func flushDigits() -> Bool {
            guard !digits.isEmpty else { return true }
            guard let value = Double(digits) else { return false }
            tokens.append(.number(value))
            digits = ""
            return true
        }

        for (index, character) in characters.enumerated() {
            let isDigit = character.isASCII && character.isNumber
            let leadsToLetter = characters.indices.contains(index + 1) && characters[index + 1].isLetter
            let continuesWord = !word.isEmpty && ((isDigit && word.lowercased() != timesLetter) || (character == "/" && leadsToLetter))
            if character.isLetter || character == "°" || continuesWord {
                guard flushDigits() else { return nil }
                word.append(character)
                continue
            }
            if isDigit || character == "." {
                flushWord()
                digits.append(character)
                continue
            }
            if character == ",", !digits.isEmpty { continue }
            flushWord()
            guard flushDigits() else { return nil }
            switch character {
            case " ": continue
            case "+": tokens.append(.plus)
            case "-", "−": tokens.append(.minus)
            case "*", "×": tokens.append(.times)
            case "/", "÷": tokens.append(.divide)
            case "^": tokens.append(.power)
            case "(": tokens.append(.open)
            case ")": tokens.append(.close)
            case "=": tokens.append(.word("="))
            default:
                guard CurrencyNames.symbols.contains(character) else { return nil }
                tokens.append(.word(String(character)))
            }
        }
        flushWord()
        guard flushDigits() else { return nil }
        return tokens
    }
}
