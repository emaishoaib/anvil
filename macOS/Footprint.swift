import AppKit

final class Footprint {
    private static let cornerRadius: CGFloat = 10
    private static let borderWidth: CGFloat = 2
    private static let fillOpacity = 0.2

    private let window = Footprint.makeWindow()

    func show(_ frameWithTopAtMinY: CGRect) {
        window.setFrame(NSScreen.appKitFrame(fromTopAtMinY: frameWithTopAtMinY), display: true)
        window.orderFrontRegardless()
    }

    func hide() {
        window.orderOut(nil)
    }

    private static func makeWindow() -> NSPanel {
        let window = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.hidesOnDeactivate = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]

        let outline = NSView()
        outline.wantsLayer = true
        outline.layer?.cornerRadius = cornerRadius
        outline.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(fillOpacity).cgColor
        outline.layer?.borderColor = NSColor.systemBlue.cgColor
        outline.layer?.borderWidth = borderWidth
        window.contentView = outline
        return window
    }
}
