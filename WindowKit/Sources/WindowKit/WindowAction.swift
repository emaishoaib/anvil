import CoreGraphics

public enum WindowAction: String, CaseIterable, Sendable {
    case leftHalf, rightHalf, centerHalf, topHalf, bottomHalf
    case topLeft, topRight, bottomLeft, bottomRight
    case firstThird, centerThird, lastThird, firstTwoThirds, lastTwoThirds
    case maximize, almostMaximize, maximizeHeight, center

    public func frame(from current: CGRect, in areaWithTopAtMinY: CGRect) -> CGRect {
        switch self {
        case .maximizeHeight: CGRect(x: current.minX, y: areaWithTopAtMinY.minY, width: current.width, height: areaWithTopAtMinY.height)
        case .center: current.centered(in: areaWithTopAtMinY)
        default: areaWithTopAtMinY.portion(across: across, down: down)
        }
    }

    private var across: Span {
        switch self {
        case .leftHalf, .topLeft, .bottomLeft: .firstHalf
        case .rightHalf, .topRight, .bottomRight: .lastHalf
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

    private var down: Span {
        switch self {
        case .topHalf, .topLeft, .topRight: .firstHalf
        case .bottomHalf, .bottomLeft, .bottomRight: .lastHalf
        case .almostMaximize: .almostWhole
        default: .whole
        }
    }
}
