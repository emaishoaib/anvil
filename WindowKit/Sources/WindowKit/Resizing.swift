import CoreGraphics

extension CGRect {
    private static let smallestShareOfArea = 0.25

    func resized(by change: CGFloat, in area: CGRect) -> CGRect {
        let width = Self.length(width, changedBy: change, smallest: (area.width * Self.smallestShareOfArea).rounded())
        let height = Self.length(height, changedBy: change, smallest: (area.height * Self.smallestShareOfArea).rounded())
        return CGRect(x: midX - width / 2, y: midY - height / 2, width: width, height: height).kept(inside: area)
    }

    func kept(inside area: CGRect) -> CGRect {
        let width = min(width, area.width)
        let height = min(height, area.height)
        let x = min(max(minX, area.minX), area.maxX - width)
        let y = min(max(minY, area.minY), area.maxY - height)
        return CGRect(x: x.rounded(), y: y.rounded(), width: width, height: height)
    }

    private static func length(_ length: CGFloat, changedBy change: CGFloat, smallest: CGFloat) -> CGFloat {
        guard change < 0 else { return length + change }
        return length <= smallest ? length : max(length + change, smallest)
    }
}
