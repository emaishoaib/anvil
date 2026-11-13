import CoreGraphics

extension CGRect {
    func centered(in area: CGRect) -> CGRect {
        let width = min(self.width, area.width)
        let height = min(self.height, area.height)
        return CGRect(x: (area.midX - width / 2).rounded(), y: (area.midY - height / 2).rounded(), width: width, height: height)
    }
}
