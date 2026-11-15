import AppKit

/// The strike the menu bar icon plays when the search bar opens: the anvil squashes down as if hit by a hammer, springs back up, and three small sparks fly off its top. It runs entirely in Core Animation, so once started it takes nothing from the main thread, and it is skipped when Reduce Motion is on. The sparks are made once and kept invisible between strikes.
enum StrikeAnimation {
    private static let strikeDuration = 0.32
    private static let sparkDuration = 0.4
    private static let squash = CGSize(width: 1.08, height: 0.82)
    private static let reboundPoints: CGFloat = 2
    private static let sparkSizePoints: CGFloat = 3
    private static let sparkRisePoints: CGFloat = 4
    private static let sparkName = "strikeSpark"
    private static let sparks: [(offsetPoints: CGFloat, delay: CFTimeInterval)] = [(-5, 0.03), (0, 0), (5, 0.05)]

    static func play(on button: NSStatusBarButton) {
        guard !PanelAnimation.isReduced, let layer = button.layer else { return }
        let up: CGFloat = button.isFlipped ? -1 : 1
        let halfIcon = (button.image?.size.height ?? 0) / 2
        let iconBottom = CGPoint(x: button.bounds.midX, y: button.bounds.midY - up * halfIcon)
        let iconTop = CGPoint(x: button.bounds.midX, y: button.bounds.midY + up * halfIcon)
        strike(layer, pivot: iconBottom, up: up)
        for (spark, flight) in zip(sparkLayers(in: layer), sparks) {
            let start = CGPoint(x: iconTop.x + flight.offsetPoints, y: iconTop.y + up * sparkSizePoints)
            let end = CGPoint(x: start.x + flight.offsetPoints * 0.6, y: start.y + up * sparkRisePoints)
            fly(spark, from: start, to: end, delay: flight.delay)
        }
    }

    private static func strike(_ layer: CALayer, pivot: CGPoint, up: CGFloat) {
        let pivotFromAnchor = CGPoint(x: pivot.x - layer.anchorPoint.x * layer.bounds.width, y: pivot.y - layer.anchorPoint.y * layer.bounds.height)
        let squashed = scaled(around: pivotFromAnchor, by: squash)
        let rebound = CATransform3DMakeTranslation(0, up * reboundPoints, 0)
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.values = [CATransform3DIdentity, squashed, rebound, CATransform3DIdentity].map { NSValue(caTransform3D: $0) }
        animation.keyTimes = [0, 0.3, 0.6, 1]
        animation.duration = strikeDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(animation, forKey: "strike")
    }

    private static func fly(_ spark: CALayer, from start: CGPoint, to end: CGPoint, delay: CFTimeInterval) {
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
        group.beginTime = CACurrentMediaTime() + delay
        group.fillMode = .backwards
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        spark.add(group, forKey: "spark")
    }

    private static func sparkLayers(in layer: CALayer) -> [CALayer] {
        let existing = layer.sublayers?.filter { $0.name == sparkName } ?? []
        guard existing.isEmpty else { return existing }
        return sparks.map { _ in
            let spark = CALayer()
            spark.name = sparkName
            spark.bounds = CGRect(x: 0, y: 0, width: sparkSizePoints, height: sparkSizePoints)
            spark.cornerRadius = sparkSizePoints / 2
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
