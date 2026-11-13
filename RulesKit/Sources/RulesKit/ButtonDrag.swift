public struct ButtonDrag: Sendable {
    static let thresholdPoints = 30.0

    public let button: Int
    private let startAcross: Double
    private let startDown: Double
    public private(set) var hasDragged = false

    public init(button: Int, across: Double, down: Double) {
        self.button = button
        startAcross = across
        startDown = down
    }

    public mutating func move(across: Double, down: Double) -> DragDirection? {
        guard !hasDragged,
              let direction = DragDirection(across: across - startAcross, down: down - startDown, thresholdPoints: Self.thresholdPoints)
        else { return nil }
        hasDragged = true
        return direction
    }
}
