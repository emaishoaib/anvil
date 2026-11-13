import RulesKit

nonisolated extension KeyCombo {
    init(_ keystroke: Keystroke) {
        self.init(keyCode: keystroke.keyCode, modifiers: KeyModifiers(rawValue: keystroke.modifiers))
    }

    var keystroke: Keystroke {
        Keystroke(keyCode: keyCode, modifiers: modifiers.rawValue)
    }
}
