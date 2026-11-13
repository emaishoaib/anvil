nonisolated enum MouseButton {
    static let numbers = [2, 3, 4, GestureButton.number]

    static func name(for number: Int) -> String {
        switch number {
        case 2: "Middle Button"
        case 3: "Back Button"
        case 4: "Forward Button"
        case GestureButton.number: "Gesture Button"
        default: "Mouse Button \(number + 1)"
        }
    }
}
