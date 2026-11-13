import Foundation

public enum AppScanner {
    public static let defaultDepth = 2

    public static func apps(in folder: URL, depth: Int = defaultDepth) -> [URL] {
        guard let items = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: nil, options: .skipsPackageDescendants) else { return [] }
        var apps: [URL] = []
        for case let url as URL in items {
            if items.level >= depth { items.skipDescendants() }
            if url.pathExtension == "app" { apps.append(url) }
        }
        return apps
    }
}
