import SwiftUI
import WebKit

struct EntryView: NSViewRepresentable {
    let page: String

    func makeNSView(context: Context) -> WKWebView {
        let view = EntryWebView.shared.view
        view.removeFromSuperview()
        EntryWebView.shared.show(page)
        return view
    }

    func updateNSView(_ view: WKWebView, context: Context) {
        EntryWebView.shared.show(page)
    }

    static func dismantleNSView(_ view: WKWebView, coordinator: ()) {
        EntryWebView.shared.clear()
    }
}

final class EntryWebView {
    static let shared = EntryWebView()

    let view = WKWebView()
    private let links = EntryLinks()
    private var page: String?

    private init() {
        view.setValue(false, forKey: "drawsBackground")
        view.navigationDelegate = links
        view.loadHTMLString("", baseURL: nil)
    }

    static func warmUp() {
        _ = shared
    }

    func show(_ page: String) {
        guard page != self.page else { return }
        self.page = page
        view.loadHTMLString(page, baseURL: nil)
    }

    func clear() {
        page = nil
        view.loadHTMLString("", baseURL: nil)
    }
}

final class EntryLinks: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
        action.navigationType == .linkActivated ? .cancel : .allow
    }
}
