import AppKit

extension NSScreen {
    static func holding(_ windowFrame: CGRect) -> NSScreen? {
        screens.max { $0.overlap(with: windowFrame) < $1.overlap(with: windowFrame) }
    }

    static func under(_ pointWithTopAtMinY: CGPoint) -> NSScreen? {
        screens.first { $0.frameWithTopAtMinY.contains(pointWithTopAtMinY) }
    }

    static func appKitFrame(fromTopAtMinY rect: CGRect) -> CGRect {
        flippedVertically(rect)
    }

    var frameWithTopAtMinY: CGRect {
        Self.flippedVertically(frame)
    }

    var visibleFrameWithTopAtMinY: CGRect {
        Self.flippedVertically(visibleFrame)
    }

    private func overlap(with windowFrame: CGRect) -> CGFloat {
        let shared = frameWithTopAtMinY.intersection(windowFrame)
        return shared.isNull ? 0 : shared.width * shared.height
    }

    private static func flippedVertically(_ rect: CGRect) -> CGRect {
        let primaryScreenHeight = screens.first?.frame.height ?? 0
        return CGRect(x: rect.minX, y: primaryScreenHeight - rect.maxY, width: rect.width, height: rect.height)
    }
}
