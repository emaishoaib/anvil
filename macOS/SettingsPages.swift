import AppKit
import SwiftUI

/// Keeps every settings page built in a view of its own, outside the window until it is shown, so only the shown page reacts when the window changes.
final class SettingsPages {
    static let shared = SettingsPages()

    private static let preparedSize = NSSize(width: 490, height: 460)

    private let viewsByPage = Dictionary(uniqueKeysWithValues: SettingsPage.all.map { ($0, SettingsPages.makeView(for: $0)) })

    func view(for page: SettingsPage) -> NSView? {
        viewsByPage[page]
    }

    func prepare() {
        for view in viewsByPage.values {
            view.setFrameSize(Self.preparedSize)
            view.layoutSubtreeIfNeeded()
        }
    }

    private static func makeView(for page: SettingsPage) -> NSView {
        let view = switch page {
        case .general: NSHostingView(rootView: AnyView(GeneralPage()))
        case .tool(let tool): NSHostingView(rootView: AnyView(ToolPage(tool: tool)))
        }
        view.sizingOptions = []
        return view
    }
}

/// The detail area of the settings window, holding only the page that is shown.
struct ShownSettingsPage: NSViewRepresentable {
    let page: SettingsPage?

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ container: NSView, context: Context) {
        let shown = page.flatMap(SettingsPages.shared.view(for:))
        guard container.subviews.first !== shown else { return }
        container.subviews.forEach { $0.removeFromSuperview() }
        guard let shown else { return }
        shown.frame = container.bounds
        shown.autoresizingMask = [.width, .height]
        container.addSubview(shown)
    }
}
