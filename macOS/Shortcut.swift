nonisolated struct Shortcut: Identifiable {
    let keys: String
    let action: String

    var id: String { keys }
}
