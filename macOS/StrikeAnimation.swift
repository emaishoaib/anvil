import AppKit

/// The strike the menu bar icon plays when the search bar opens: the anvil squashes down as if hit by a hammer, springs back up, and three small sparks fly off its top. It can also play over and over with a pause between hits, until it is stopped, and on a smaller anvil anywhere else, such as the anvil shown while something loads, with its bounce and sparks scaled down to match. It runs entirely in Core Animation, so once started it takes nothing from the main thread, and it is skipped when Reduce Motion is on. The sparks are made once and kept invisible between strikes.
enum StrikeAnimation {
    static let repeatSeconds = 0.9
    private static let strikeDuration = 0.32
    private static let sparkDuration = 0.4
    private static let squash = CGSize(width: 1.08, height: 0.82)
    private static let reboundPoints: CGFloat = 2
    private static let sparkSizePoints: CGFloat = 3
    private static let sparkRisePoints: CGFloat = 4
    private static let sparkName = "strikeSpark"
    private static let sparks: [(offsetPoints: CGFloat, delay: CFTimeInterval)] = [(-5, 0.03), (0, 0), (5, 0.05)]

    static func play(on button: NSStatusBarButton, repeating: Bool = false) {
        guard let layer = button.layer else { return }
        let up: CGFloat = button.isFlipped ? -1 : 1
        let halfIcon = (button.image?.size.height ?? 0) / 2
        let base = CGPoint(x: button.bounds.midX, y: button.bounds.midY - up * halfIcon)
        let top = CGPoint(x: button.bounds.midX, y: button.bounds.midY + up * halfIcon)
        play(on: layer, base: base, top: top, up: up, scale: 1, repeating: repeating)
    }

    /// Plays the strike on any layer, given where the middle of the anvil's base and top sit in it, which way is up, and how large the anvil is next to the menu bar's.
    static func play(on layer: CALayer, base: CGPoint, top: CGPoint, up: CGFloat, scale: CGFloat, repeating: Bool) {
        guard !PanelAnimation.isReduced else { return }
        strike(layer, pivot: base, up: up, scale: scale, repeating: repeating)
        for (spark, flight) in zip(sparkLayers(in: layer, scale: scale), sparks) {
            let start = CGPoint(x: top.x + flight.offsetPoints * scale, y: top.y + up * sparkSizePoints * scale)
            let end = CGPoint(x: start.x + flight.offsetPoints * scale * 0.6, y: start.y + up * sparkRisePoints * scale)
            fly(spark, from: start, to: end, delay: flight.delay, repeating: repeating)
        }
    }

    /// Ends a strike playing over and over, leaving the icon and sparks as they are between strikes.
    static func stop(on button: NSStatusBarButton) {
        guard let layer = button.layer else { return }
        layer.removeAnimation(forKey: "strike")
        for spark in existingSparks(in: layer) { spark.removeAnimation(forKey: "spark") }
    }

    private static func strike(_ layer: CALayer, pivot: CGPoint, up: CGFloat, scale: CGFloat, repeating: Bool) {
        let pivotFromAnchor = CGPoint(x: pivot.x - layer.anchorPoint.x * layer.bounds.width, y: pivot.y - layer.anchorPoint.y * layer.bounds.height)
        let squashed = scaled(around: pivotFromAnchor, by: squash)
        let rebound = CATransform3DMakeTranslation(0, up * reboundPoints * scale, 0)
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.values = [CATransform3DIdentity, squashed, rebound, CATransform3DIdentity].map { NSValue(caTransform3D: $0) }
        animation.keyTimes = [0, 0.3, 0.6, 1]
        animation.duration = strikeDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(cycle(animation, lasting: strikeDuration, repeating: repeating), forKey: "strike")
    }

    private static func fly(_ spark: CALayer, from start: CGPoint, to end: CGPoint, delay: CFTimeInterval, repeating: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        spark.position = start
        CATransaction.commit()

        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = [0, 1, 0]
        fade.keyTimes = [0, 0.25, 1]
        let grow = CABasicAnimation(keyPath: "transform.scale")
        grow.fromValue = 0.4
        grow.toValue = 1.6
        let rise = CABasicAnimation(keyPath: "position")
        rise.fromValue = NSValue(point: start)
        rise.toValue = NSValue(point: end)
        let group = CAAnimationGroup()
        group.animations = [fade, grow, rise]
        group.duration = sparkDuration
        group.beginTime = delay
        group.fillMode = .backwards
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        spark.add(cycle(group, lasting: delay + sparkDuration, repeating: repeating), forKey: "spark")
    }

    /// Wraps part of the strike in one whole strike's time, played once or over and over, so a repeating strike pauses between hits and its sparks stay in step with it.
    private static func cycle(_ animation: CAAnimation, lasting seconds: CFTimeInterval, repeating: Bool) -> CAAnimation {
        let cycle = CAAnimationGroup()
        cycle.animations = [animation]
        cycle.duration = repeating ? repeatSeconds : seconds
        cycle.repeatCount = repeating ? .infinity : 1
        return cycle
    }

    private static func existingSparks(in layer: CALayer) -> [CALayer] {
        layer.sublayers?.filter { $0.name == sparkName } ?? []
    }

    private static func sparkLayers(in layer: CALayer, scale: CGFloat) -> [CALayer] {
        let existing = existingSparks(in: layer)
        guard existing.isEmpty else { return existing }
        let size = sparkSizePoints * scale
        return sparks.map { _ in
            let spark = CALayer()
            spark.name = sparkName
            spark.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            spark.cornerRadius = size / 2
            spark.backgroundColor = NSColor.systemOrange.cgColor
            spark.opacity = 0
            layer.addSublayer(spark)
            return spark
        }
    }

    private static func scaled(around pivot: CGPoint, by factor: CGSize) -> CATransform3D {
        let toPivot = CATransform3DMakeTranslation(pivot.x, pivot.y, 0)
        let scale = CATransform3DScale(toPivot, factor.width, factor.height, 1)
        return CATransform3DTranslate(scale, -pivot.x, -pivot.y, 0)
    }
}
