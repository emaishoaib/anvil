import AppKit

/// The anvil a loader shows: the menu bar's icon in the secondary text colour, sitting at the bottom with room above it for the strike's bounce and sparks. Both animations run in Core Animation, so they keep moving while the main thread is busy, and the anvil stays still when Reduce Motion is on. It starts animating as it appears and starts afresh when the appearance changes, since the glow's colours are worked out for light or dark.
final class AnvilLoaderView: NSView {
    private static let menuBarAnvilWidth: CGFloat = 22
    private static let sparkRoomPoints: CGFloat = 10

    private let anvilSize: CGSize
    private let scale: CGFloat
    private let anvil = CALayer()
    private let shape = CALayer()

    init(anvilWidth: CGFloat) {
        let icon = NSImage(resource: .menuBarIcon)
        anvilSize = CGSize(width: anvilWidth, height: anvilWidth * icon.size.height / icon.size.width)
        scale = anvilWidth / Self.menuBarAnvilWidth
        super.init(frame: .zero)
        wantsLayer = true
        shape.contents = icon
        shape.contentsGravity = .resizeAspect
        anvil.mask = shape
        layer?.addSublayer(anvil)
    }

    required init?(coder: NSCoder) { nil }

    override var intrinsicContentSize: NSSize {
        NSSize(width: anvilSize.width, height: anvilSize.height + Self.sparkRoomPoints * scale)
    }

    override var wantsUpdateLayer: Bool { true }

    override func updateLayer() {
        anvil.backgroundColor = NSColor.secondaryLabelColor.cgColor
    }

    override func layout() {
        super.layout()
        anvil.frame = CGRect(origin: CGPoint(x: bounds.midX - anvilSize.width / 2, y: 0), size: anvilSize)
        shape.frame = anvil.bounds
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        shape.contentsScale = window?.backingScaleFactor ?? 2
        if window != nil { animate() }
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        needsDisplay = true
        if window != nil { animate() }
    }

    private func animate() {
        guard !PanelAnimation.isReduced, let layer else { return }
        layoutSubtreeIfNeeded()
        switch WorkingAnimation.current {
        case .strike:
            let base = CGPoint(x: anvil.frame.midX, y: anvil.frame.minY)
            let top = CGPoint(x: anvil.frame.midX, y: anvil.frame.maxY)
            StrikeAnimation.play(on: layer, base: base, top: top, up: 1, scale: scale, repeating: true)
        case .glow:
            anvil.add(glow, forKey: "glow")
        }
    }

    private var glow: CAAnimation {
        var colours = (cool: CGColor.clear, hot: CGColor.clear)
        effectiveAppearance.performAsCurrentDrawingAppearance {
            colours = (NSColor.secondaryLabelColor.cgColor, NSColor.systemOrange.cgColor)
        }
        let glow = CABasicAnimation(keyPath: "backgroundColor")
        glow.fromValue = colours.cool
        glow.toValue = colours.hot
        glow.duration = HeatAnimation.cycleSeconds / 2
        glow.autoreverses = true
        glow.repeatCount = .infinity
        glow.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return glow
    }
}
