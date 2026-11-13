nonisolated protocol KeyResponder: Sendable {
    var shortcuts: [Shortcut] { get }
    func respond(to press: KeyPress) -> Bool
}
