import CoreGraphics

extension SnapZone {
    private static let nearCornerLengthPoints: CGFloat = 145

    public var defaultChoice: ZoneChoice {
        switch self {
        case .topLeft: .action(.topLeft)
        case .top: .action(.maximize)
        case .topRight: .action(.topRight)
        case .left, .right: .halfWithTopOrBottomNearCorners
        case .bottomLeft: .action(.bottomLeft)
        case .bottom: .thirdsWithTwoThirdsTowardCenter
        case .bottomRight: .action(.bottomRight)
        }
    }

    public var choices: [ZoneChoice] {
        let special: [ZoneChoice] = switch self {
        case .left, .right: [.halfWithTopOrBottomNearCorners]
        case .top, .bottom: [.thirdsWithTwoThirdsTowardCenter]
        default: []
        }
        return [.nothing] + special + ZoneChoice.actions.map(ZoneChoice.action)
    }

    public func action(for choice: ZoneChoice, at point: CGPoint, on screenWithTopAtMinY: CGRect, previous: WindowAction?) -> WindowAction? {
        switch choice {
        case .nothing: nil
        case .action(let action): action
        case .halfWithTopOrBottomNearCorners: half(at: point, on: screenWithTopAtMinY)
        case .thirdsWithTwoThirdsTowardCenter: Self.third(at: point, on: screenWithTopAtMinY, previous: previous)
        }
    }

    private func half(at point: CGPoint, on screen: CGRect) -> WindowAction {
        if point.y <= screen.minY + Self.nearCornerLengthPoints { return .topHalf }
        if point.y >= screen.maxY - Self.nearCornerLengthPoints { return .bottomHalf }
        return self == .right ? .rightHalf : .leftHalf
    }

    private static func third(at point: CGPoint, on screen: CGRect, previous: WindowAction?) -> WindowAction {
        switch (point.x - screen.minX) / screen.width {
        case ..<(1.0 / 3): .firstThird
        case (2.0 / 3)...: .lastThird
        default:
            switch previous {
            case .firstThird, .firstTwoThirds: .firstTwoThirds
            case .lastThird, .lastTwoThirds: .lastTwoThirds
            default: .centerThird
            }
        }
    }
}
