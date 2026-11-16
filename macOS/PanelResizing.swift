import AppKit

/// Where the search bar sits and how it moves between its usual size and the larger one AI mode can grow to. Its usual place is centred near the top of the screen, and the larger size is wide enough to read comfortably and nearly as tall as the screen's free area, centred in it. On a narrow screen the width shrinks to fit. The move between them animates unless reduced motion is on.
enum PanelResizing {
    private static let topShare = 0.25
    private static let expandedWidth: CGFloat = 960
    private static let expandedWidthShare = 0.9
    private static let expandedHeightShare = 0.8
    private static let duration = 0.25

    static func usualFrame(for size: CGSize, on screen: NSScreen) -> NSRect {
        let top = screen.frame.maxY - screen.frame.height * topShare
        return NSRect(x: screen.frame.midX - size.width / 2, y: top - size.height, width: size.width, height: size.height)
    }

    static func expandedFrame(on screen: NSScreen) -> NSRect {
        let area = screen.visibleFrame
        let size = CGSize(width: min(expandedWidth, area.width * expandedWidthShare), height: area.height * expandedHeightShare)
        return NSRect(x: area.midX - size.width / 2, y: area.midY - size.height / 2, width: size.width, height: size.height)
    }

    static func animate(_ panel: NSPanel, to frame: NSRect, then finish: @escaping @MainActor () -> Void = {}) {
        guard !PanelAnimation.isReduced else {
            panel.setFrame(frame, display: true)
            return finish()
        }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(frame, display: true)
        }, completionHandler: {
            MainActor.assumeIsolated { finish() }
        })
    }
}
