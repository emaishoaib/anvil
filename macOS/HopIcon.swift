import SwiftUI

/// The Switcher's icon, drawn the way Hop's app icon was: four windows in a 2 by 2 grid, with the top right one picked out as the window being switched to. The other three show only their outlines, faded, so the icon reads in one colour beside SF Symbols. The proportions are Hop's, measured against one window's width.
struct HopIcon: View {
    private static let windowHeightRatio: CGFloat = 206.0 / 261
    private static let gapRatio: CGFloat = 55.0 / 261
    private static let cornerRatio: CGFloat = 34.0 / 261
    private static let outlineRatio: CGFloat = 0.17
    private static let fadedOpacity = 0.45
    private static let selectedWindow = (column: 1, row: 0)

    var body: some View {
        Canvas { context, size in
            let windowWidth = size.width / (2 + Self.gapRatio)
            let windowHeight = windowWidth * Self.windowHeightRatio
            let gap = windowWidth * Self.gapRatio
            let outline = max(1, windowWidth * Self.outlineRatio)
            let top = (size.height - windowHeight * 2 - gap) / 2
            for column in 0..<2 {
                for row in 0..<2 {
                    let frame = CGRect(x: CGFloat(column) * (windowWidth + gap), y: top + CGFloat(row) * (windowHeight + gap), width: windowWidth, height: windowHeight)
                    let window = Path(roundedRect: frame.insetBy(dx: outline / 2, dy: outline / 2), cornerRadius: windowWidth * Self.cornerRatio)
                    guard (column, row) != Self.selectedWindow else {
                        context.fill(window, with: .foreground)
                        continue
                    }
                    var faded = context
                    faded.opacity = Self.fadedOpacity
                    faded.stroke(window, with: .foreground, lineWidth: outline)
                }
            }
        }
    }
}
