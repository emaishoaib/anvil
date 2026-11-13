import CoreGraphics

public enum WindowAction: String, CaseIterable, Sendable {
    case leftHalf, rightHalf, centerHalf, topHalf, bottomHalf
    case topLeft, topRight, bottomLeft, bottomRight
    case firstThird, centerThird, lastThird, firstTwoThirds, lastTwoThirds

    public func frame(in areaWithTopAtMinY: CGRect) -> CGRect {
        areaWithTopAtMinY.portion(across: across, down: down)
    }

    private var across: Span {
        switch self {
        case .leftHalf, .topLeft, .bottomLeft: .firstHalf
        case .rightHalf, .topRight, .bottomRight: .lastHalf
        case .centerHalf: .centerHalf
        case .topHalf, .bottomHalf: .whole
        case .firstThird: .firstThird
        case .centerThird: .centerThird
        case .lastThird: .lastThird
        case .firstTwoThirds: .firstTwoThirds
        case .lastTwoThirds: .lastTwoThirds
        }
    }

    private var down: Span {
        switch self {
        case .topHalf, .topLeft, .topRight: .firstHalf
        case .bottomHalf, .bottomLeft, .bottomRight: .lastHalf
        default: .whole
        }
    }
}
