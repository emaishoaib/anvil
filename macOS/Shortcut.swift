nonisolated struct Shortcut: Identifiable {
    let combo: KeyCombo
    let action: String

    var id: KeyCombo { combo }
    var keys: String { combo.description }
}
