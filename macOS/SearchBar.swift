import AppKit
import Carbon.HIToolbox
import SwiftUI

final class SearchBar {
    static let shared = SearchBar()

    private static let topShare = 0.25

    private let panel = SearchPanel()
    private var model = SearchModel()

    func toggle() {
        panel.isVisible ? hide() : show()
    }

    func hide() {
        guard panel.isVisible else { return }
        panel.orderOut(nil)
    }

    func fit(height: CGFloat) {
        guard panel.frame.height != height else { return }
        var frame = panel.frame
        frame.origin.y = frame.maxY - height
        frame.size.height = height
        panel.setFrame(frame, display: true)
    }

    func handleKey(_ keyCode: Int) -> Bool {
        switch keyCode {
        case kVK_UpArrow: model.moveSelection(by: -1)
        case kVK_DownArrow: model.moveSelection(by: 1)
        case kVK_Return, kVK_ANSI_KeypadEnter: model.openSelected()
        case kVK_Escape: if !model.goBack() { hide() }
        case kVK_Delete: guard model.query.isEmpty, model.goBack() else { return false }
        default: return false
        }
        return true
    }

    private func show() {
        guard let screen = NSScreen.main, let background = panel.contentView else { return }
        CurrencyRatesStore.shared.refreshIfStale()
        model = SearchModel()
        let content = NSHostingView(rootView: SearchBarView(model: model))
        let size = content.fittingSize
        let top = screen.frame.maxY - screen.frame.height * Self.topShare
        panel.setFrame(NSRect(x: screen.frame.midX - size.width / 2, y: top - size.height, width: size.width, height: size.height), display: true)
        content.frame = background.bounds
        content.autoresizingMask = [.width, .height]
        background.subviews.forEach { $0.removeFromSuperview() }
        background.addSubview(content)
        PanelAnimation.appear(panel)
        panel.makeKeyAndOrderFront(nil)
    }
}
