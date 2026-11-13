import AppKit

/// Keeps each file's icon after macOS first hands it over, so redrawing a row never asks for it again.
final class AppIcons {
    static let shared = AppIcons()

    private var iconsByPath: [String: NSImage] = [:]

    func icon(forFile path: String) -> NSImage {
        if let icon = iconsByPath[path] { return icon }
        let icon = NSWorkspace.shared.icon(forFile: path)
        iconsByPath[path] = icon
        return icon
    }
}
