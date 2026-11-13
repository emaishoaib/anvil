import Carbon.HIToolbox

nonisolated struct KeyCombo: Hashable, CustomStringConvertible {
    let keyCode: Int
    let modifiers: KeyModifiers

    var description: String {
        "\(modifiers.symbols) \(keyName)"
    }

    var keyName: String {
        KeyNames.name(for: keyCode)
    }

    var savedText: String {
        "\(keyCode):\(modifiers.rawValue)"
    }
}

extension KeyCombo {
    nonisolated init?(savedText: String) {
        let numbers = savedText.split(separator: ":").compactMap { Int($0) }
        guard numbers.count == 2 else { return nil }
        self.init(keyCode: numbers[0], modifiers: KeyModifiers(rawValue: numbers[1]))
    }
}
