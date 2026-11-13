import CoreGraphics

public struct RestoreFrames: Sendable {
    private struct Saved: Sendable {
        let beforeFirstSnap: CGRect
        let landedAt: CGRect
    }

    private var byWindow: [CGWindowID: Saved] = [:]

    public init() {}

    public mutating func recordSnap(of window: CGWindowID, from frame: CGRect, landedAt: CGRect) {
        let stillSnapped = byWindow[window].flatMap { $0.landedAt == frame ? $0.beforeFirstSnap : nil }
        byWindow[window] = Saved(beforeFirstSnap: stillSnapped ?? frame, landedAt: landedAt)
    }

    public mutating func takeFrame(for window: CGWindowID) -> CGRect? {
        byWindow.removeValue(forKey: window)?.beforeFirstSnap
    }
}
