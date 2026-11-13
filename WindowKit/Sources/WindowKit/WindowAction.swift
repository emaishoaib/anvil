import CoreGraphics

public enum WindowAction: String, CaseIterable, Sendable {
    case leftHalf, rightHalf, centerHalf, topHalf, bottomHalf
    case topLeft, topRight, bottomLeft, bottomRight
    case firstThird, centerThird, lastThird, firstTwoThirds, lastTwoThirds
    case maximize, almostMaximize, maximizeHeight, center
    case makeSmaller, makeLarger
    case moveLeft, moveRight, moveUp, moveDown

    private static let resizeStepPoints: CGFloat = 30
    private static let cycledHalfShares = [1.0 / 2, 2.0 / 3, 1.0 / 3]

    public func frame(from current: CGRect, in areaWithTopAtMinY: CGRect, repeats: Int = 0) -> CGRect {
        let halfShare = Self.cycledHalfShares[repeats % Self.cycledHalfShares.count]
        return switch self {
        case .maximizeHeight: CGRect(x: current.minX, y: areaWithTopAtMinY.minY, width: current.width, height: areaWithTopAtMinY.height)
        case .center: current.centered(in: areaWithTopAtMinY)
        case .makeSmaller: current.resized(by: -Self.resizeStepPoints, in: areaWithTopAtMinY)
        case .makeLarger: current.resized(by: Self.resizeStepPoints, in: areaWithTopAtMinY)
        case .moveLeft: current.moved(to: .left, in: areaWithTopAtMinY)
        case .moveRight: current.moved(to: .right, in: areaWithTopAtMinY)
        case .moveUp: current.moved(to: .top, in: areaWithTopAtMinY)
        case .moveDown: current.moved(to: .bottom, in: areaWithTopAtMinY)
        default: areaWithTopAtMinY.portion(across: across(halfShare), down: down(halfShare))
        }
    }

    private func across(_ halfShare: Double) -> Span {
        switch self {
        case .leftHalf: .first(halfShare)
        case .rightHalf: .last(halfShare)
        case .topLeft, .bottomLeft: .firstHalf
        case .topRight, .bottomRight: .lastHalf
        case .centerHalf: .centerHalf
        case .firstThird: .firstThird
        case .centerThird: .centerThird
        case .lastThird: .lastThird
        case .firstTwoThirds: .firstTwoThirds
        case .lastTwoThirds: .lastTwoThirds
        case .almostMaximize: .almostWhole
        default: .whole
        }
    }

    private func down(_ halfShare: Double) -> Span {
        switch self {
        case .topHalf: .first(halfShare)
        case .bottomHalf: .last(halfShare)
        case .topLeft, .topRight: .firstHalf
        case .bottomLeft, .bottomRight: .lastHalf
        case .almostMaximize: .almostWhole
        default: .whole
        }
    }
}
