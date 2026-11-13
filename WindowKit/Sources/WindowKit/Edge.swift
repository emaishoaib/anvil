import CoreGraphics

enum Edge {
    case left, right, top, bottom
}

extension CGRect {
    func moved(to edge: Edge, in area: CGRect) -> CGRect {
        var frame = kept(inside: area)
        switch edge {
        case .left: frame.origin.x = area.minX
        case .right: frame.origin.x = area.maxX - frame.width
        case .top: frame.origin.y = area.minY
        case .bottom: frame.origin.y = area.maxY - frame.height
        }
        return frame
    }
}
