import CoreGraphics

public struct RepeatedSnaps: Sendable {
    private struct Snap: Sendable {
        let action: WindowAction
        let window: CGWindowID
        let repeats: Int
        let landedAt: CGRect
    }

    private var last: Snap?

    public init() {}

    public func repeats(of action: WindowAction, on window: CGWindowID, at frame: CGRect) -> Int {
        guard let last, last.action == action, last.window == window, last.landedAt == frame else { return 0 }
        return last.repeats + 1
    }

    public mutating func record(_ action: WindowAction, on window: CGWindowID, repeats: Int, landedAt frame: CGRect) {
        last = Snap(action: action, window: window, repeats: repeats, landedAt: frame)
    }
}
