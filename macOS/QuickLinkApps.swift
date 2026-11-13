import AppKit
import LauncherKit

extension QuickLink {
    var app: URL? { openWith ?? defaultApp }

    var defaultApp: URL? {
        probe.flatMap(DefaultApps.shared.app(toOpen:))
    }

    var appChoices: [URL] {
        probe.map(NSWorkspace.shared.urlsForApplications(toOpen:)) ?? []
    }

    private var probe: URL? {
        if isFilePath { return target }
        return scheme.flatMap { URL(string: "\($0):") }
    }
}

extension URL {
    var appName: String { deletingPathExtension().lastPathComponent }

    var menuIcon: NSImage {
        let icon = NSWorkspace.shared.icon(forFile: path)
        icon.size = NSSize(width: 16, height: 16)
        return icon
    }
}
