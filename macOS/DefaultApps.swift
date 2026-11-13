import AppKit

/// Keeps the app macOS opens each kind of link with, so redrawing a row never asks Launch Services again.
final class DefaultApps {
    static let shared = DefaultApps()

    private var appsByProbe: [URL: URL?] = [:]

    func app(toOpen probe: URL) -> URL? {
        if let app = appsByProbe[probe] { return app }
        let app = NSWorkspace.shared.urlForApplication(toOpen: probe)
        appsByProbe[probe] = app
        return app
    }
}
