import CoreGraphics

extension CGRect {
    public func resized(to size: CGSize, keepingPointerAt pointer: CGPoint) -> CGRect {
        let pointerShareAcross = width > 0 ? (pointer.x - minX) / width : 0.5
        return CGRect(x: (pointer.x - pointerShareAcross * size.width).rounded(), y: minY, width: size.width, height: size.height)
    }
}
