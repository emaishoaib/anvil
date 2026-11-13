import CoreGraphics

public enum SnapZone: String, Sendable, CaseIterable {
    case topLeft, top, topRight, left, right, bottomLeft, bottom, bottomRight

    private static let edgeMarginPoints: CGFloat = 5
    private static let cornerLengthPoints: CGFloat = 20

    public init?(at point: CGPoint, on screenWithTopAtMinY: CGRect) {
        let screen = screenWithTopAtMinY
        let nearLeft = point.x <= screen.minX + Self.edgeMarginPoints
        let nearRight = point.x >= screen.maxX - Self.edgeMarginPoints
        let nearTop = point.y <= screen.minY + Self.edgeMarginPoints
        let nearBottom = point.y >= screen.maxY - Self.edgeMarginPoints
        let leftCorner = point.x <= screen.minX + Self.cornerLengthPoints
        let rightCorner = point.x >= screen.maxX - Self.cornerLengthPoints
        let topCorner = point.y <= screen.minY + Self.cornerLengthPoints
        let bottomCorner = point.y >= screen.maxY - Self.cornerLengthPoints
        if (nearLeft && topCorner) || (nearTop && leftCorner) {
            self = .topLeft
        } else if (nearRight && topCorner) || (nearTop && rightCorner) {
            self = .topRight
        } else if (nearLeft && bottomCorner) || (nearBottom && leftCorner) {
            self = .bottomLeft
        } else if (nearRight && bottomCorner) || (nearBottom && rightCorner) {
            self = .bottomRight
        } else if nearLeft {
            self = .left
        } else if nearRight {
            self = .right
        } else if nearTop {
            self = .top
        } else if nearBottom {
            self = .bottom
        } else {
            return nil
        }
    }
}
