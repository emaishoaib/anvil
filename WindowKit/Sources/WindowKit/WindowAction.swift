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

    public func frame(from current: CGRect, in areaWithTopAtMinY: CGRect, repeats: Int = 0, gap: CGFloat = 0) -> CGRect {
        let halfShare = Self.cycledHalfShares[repeats % Self.cycledHalfShares.count]
        let areaInsideEdgeGap = areaWithTopAtMinY.insetBy(dx: gap, dy: gap)
        let areaSharedByTiles = areaWithTopAtMinY.insetBy(dx: gap / 2, dy: gap / 2)
        return switch self {
        case .maximizeHeight: CGRect(x: current.minX, y: areaInsideEdgeGap.minY, width: current.width, height: areaInsideEdgeGap.height)
        case .center: current.centered(in: areaInsideEdgeGap)
        case .makeSmaller: current.resized(by: -Self.resizeStepPoints, in: areaInsideEdgeGap)
        case .makeLarger: current.resized(by: Self.resizeStepPoints, in: areaInsideEdgeGap)
        case .moveLeft: current.moved(to: .left, in: areaInsideEdgeGap)
        case .moveRight: current.moved(to: .right, in: areaInsideEdgeGap)
        case .moveUp: current.moved(to: .top, in: areaInsideEdgeGap)
        case .moveDown: current.moved(to: .bottom, in: areaInsideEdgeGap)
        default: areaSharedByTiles.portion(across: across(halfShare), down: down(halfShare)).insetBy(dx: gap / 2, dy: gap / 2)
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
