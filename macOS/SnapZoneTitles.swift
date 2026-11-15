import WindowKit

extension SnapZone {
    var title: String {
        switch self {
        case .topLeft: "Top left corner"
        case .top: "Top edge"
        case .topRight: "Top right corner"
        case .left: "Left edge"
        case .right: "Right edge"
        case .bottomLeft: "Bottom left corner"
        case .bottom: "Bottom edge"
        case .bottomRight: "Bottom right corner"
        }
    }
}

extension ZoneChoice {
    func title(in zone: SnapZone) -> String {
        switch self {
        case .nothing: "Nothing"
        case .action(let action): action.title
        case .halfWithTopOrBottomNearCorners: "\(zone == .right ? "Right" : "Left") half, top or bottom half near the corners"
        case .thirdsWithTwoThirdsTowardCenter: "Thirds, two thirds when dragged toward the center"
        }
    }
}
