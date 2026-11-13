public enum ZoneChoice: Hashable, Sendable {
    case nothing
    case action(WindowAction)
    case halfWithTopOrBottomNearCorners
    case thirdsWithTwoThirdsTowardCenter

    static let actions: [WindowAction] = [
        .leftHalf, .rightHalf, .centerHalf, .topHalf, .bottomHalf,
        .topLeft, .topRight, .bottomLeft, .bottomRight,
        .firstThird, .centerThird, .lastThird, .firstTwoThirds, .lastTwoThirds,
        .maximize, .almostMaximize,
    ]
}

extension ZoneChoice: RawRepresentable {
    private static let nothingName = "nothing"
    private static let halfWithTopOrBottomNearCornersName = "halfWithTopOrBottomNearCorners"
    private static let thirdsWithTwoThirdsTowardCenterName = "thirdsWithTwoThirdsTowardCenter"

    public init?(rawValue: String) {
        switch rawValue {
        case Self.nothingName: self = .nothing
        case Self.halfWithTopOrBottomNearCornersName: self = .halfWithTopOrBottomNearCorners
        case Self.thirdsWithTwoThirdsTowardCenterName: self = .thirdsWithTwoThirdsTowardCenter
        default:
            guard let action = WindowAction(rawValue: rawValue) else { return nil }
            self = .action(action)
        }
    }

    public var rawValue: String {
        switch self {
        case .nothing: Self.nothingName
        case .action(let action): action.rawValue
        case .halfWithTopOrBottomNearCorners: Self.halfWithTopOrBottomNearCornersName
        case .thirdsWithTwoThirdsTowardCenter: Self.thirdsWithTwoThirdsTowardCenterName
        }
    }
}
