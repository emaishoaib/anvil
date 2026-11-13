import CoreGraphics

struct Span: Sendable {
    static let whole = Span(0, 1)
    static let almostWhole = Span(0.05, 0.95)
    static let firstHalf = Span(0, 1.0 / 2)
    static let lastHalf = Span(1.0 / 2, 1)
    static let centerHalf = Span(1.0 / 4, 3.0 / 4)
    static let firstThird = Span(0, 1.0 / 3)
    static let centerThird = Span(1.0 / 3, 2.0 / 3)
    static let lastThird = Span(2.0 / 3, 1)
    static let firstTwoThirds = Span(0, 2.0 / 3)
    static let lastTwoThirds = Span(1.0 / 3, 1)

    let start: Double
    let end: Double

    init(_ start: Double, _ end: Double) {
        self.start = start
        self.end = end
    }

    static func first(_ share: Double) -> Span {
        Span(0, share)
    }

    static func last(_ share: Double) -> Span {
        Span(1 - share, 1)
    }
}

extension CGRect {
    func portion(across: Span, down: Span) -> CGRect {
        let left = minX + (width * across.start).rounded()
        let right = minX + (width * across.end).rounded()
        let top = minY + (height * down.start).rounded()
        let bottom = minY + (height * down.end).rounded()
        return CGRect(x: left, y: top, width: right - left, height: bottom - top)
    }
}
