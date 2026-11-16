import AppKit

/// The glow the menu bar icon plays while Anvil works in the background: an orange copy of the anvil, cut to its shape, warms up over the icon and cools again, over and over. It waits a moment before the first warming, so work that ends quickly never shows, and it cools off gently when the work stops. Like the strike, it runs in Core Animation and is skipped when Reduce Motion is on.
enum HeatAnimation {
    private static let glowName = "heatGlow"
    private static let heatKey = "heat"
    private static let coolKey = "cool"
    private static let cycleDuration = 1.6
    private static let startDelay = 0.3
    private static let coolDuration = 0.3
    private static let peakOpacity: Float = 0.85

    static func set(_ isHot: Bool, on button: NSStatusBarButton) {
        guard let layer = button.layer else { return }
        if isHot { heat(button, layer) } else { cool(layer) }
    }

    private static func heat(_ button: NSStatusBarButton, _ layer: CALayer) {
        guard !PanelAnimation.isReduced, let icon = button.image else { return }
        let glow = glowLayer(in: layer)
        guard glow.animation(forKey: heatKey) == nil else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        glow.frame = CGRect(
            x: button.bounds.midX - icon.size.width / 2,
            y: button.bounds.midY - icon.size.height / 2,
            width: icon.size.width,
            height: icon.size.height
        )
        glow.mask?.frame = glow.bounds
        glow.mask?.contents = icon
        CATransaction.commit()

        let pulse = CAKeyframeAnimation(keyPath: "opacity")
        pulse.values = [0, peakOpacity, 0]
        pulse.keyTimes = [0, 0.5, 1]
        pulse.duration = cycleDuration
        pulse.repeatCount = .infinity
        pulse.beginTime = CACurrentMediaTime() + startDelay
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glow.removeAnimation(forKey: coolKey)
        glow.add(pulse, forKey: heatKey)
    }

    private static func cool(_ layer: CALayer) {
        guard let glow = layer.sublayers?.first(where: { $0.name == glowName }),
              glow.animation(forKey: heatKey) != nil
        else { return }
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = glow.presentation()?.opacity ?? 0
        fade.toValue = 0
        fade.duration = coolDuration
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)
        glow.removeAnimation(forKey: heatKey)
        glow.add(fade, forKey: coolKey)
    }

    private static func glowLayer(in layer: CALayer) -> CALayer {
        if let existing = layer.sublayers?.first(where: { $0.name == glowName }) { return existing }
        let glow = CALayer()
        glow.name = glowName
        glow.backgroundColor = NSColor.systemOrange.cgColor
        glow.opacity = 0
        let shape = CALayer()
        shape.contentsGravity = .resizeAspect
        glow.mask = shape
        layer.addSublayer(glow)
        return glow
    }
}
