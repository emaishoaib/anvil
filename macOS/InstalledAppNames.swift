import AppKit
import RulesKit
import UniformTypeIdentifiers

enum InstalledAppNames {
    static func url(for bundleID: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
    }

    static func name(for bundleID: String) -> String {
        url(for: bundleID)?.appName ?? bundleID
    }

    static func chooseApps() -> [String] {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = true
        panel.directoryURL = URL(filePath: "/Applications")
        panel.message = "Choose the apps this rule works in"
        guard panel.runModal() == .OK else { return [] }
        return panel.urls.compactMap { Bundle(url: $0)?.bundleIdentifier }
    }
}

extension RuleApps {
    var summary: String {
        switch self {
        case .all: "All apps"
        case .only(let bundleIDs): bundleIDs.map(InstalledAppNames.name).sorted().formatted(.list(type: .and))
        }
    }
}
