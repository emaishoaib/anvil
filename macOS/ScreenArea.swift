import AppKit

extension NSScreen {
    static func holding(_ windowFrame: CGRect) -> NSScreen? {
        screens.max { $0.overlap(with: windowFrame) < $1.overlap(with: windowFrame) }
    }

    var visibleFrameWithTopAtMinY: CGRect {
        Self.withTopAtMinY(visibleFrame)
    }

    private func overlap(with windowFrame: CGRect) -> CGFloat {
        let shared = Self.withTopAtMinY(frame).intersection(windowFrame)
        return shared.isNull ? 0 : shared.width * shared.height
    }

    private static func withTopAtMinY(_ rect: CGRect) -> CGRect {
        let primaryScreenHeight = screens.first?.frame.height ?? 0
        return CGRect(x: rect.minX, y: primaryScreenHeight - rect.maxY, width: rect.width, height: rect.height)
    }
}
