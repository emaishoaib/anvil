import AppKit
import SwiftUI

final class SearchBar {
    static let shared = SearchBar()

    private static let topShare = 0.25

    private let panel = SearchPanel()

    func toggle() {
        panel.isVisible ? hide() : show()
    }

    func hide() {
        guard panel.isVisible else { return }
        panel.orderOut(nil)
    }

    private func show() {
        guard let screen = NSScreen.main, let background = panel.contentView else { return }
        let content = NSHostingView(rootView: SearchBarView())
        let size = content.fittingSize
        content.frame = NSRect(origin: .zero, size: size)
        content.autoresizingMask = [.width, .height]
        background.subviews.forEach { $0.removeFromSuperview() }
        background.addSubview(content)
        let top = screen.frame.maxY - screen.frame.height * Self.topShare
        panel.setFrame(NSRect(x: screen.frame.midX - size.width / 2, y: top - size.height, width: size.width, height: size.height), display: true)
        PanelAnimation.appear(panel)
        panel.makeKeyAndOrderFront(nil)
    }
}
