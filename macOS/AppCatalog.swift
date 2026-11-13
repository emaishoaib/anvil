import CoreServices
import Foundation
import Observation

@Observable final class AppCatalog {
    static let shared = AppCatalog()

    private static let folders = [
        URL(filePath: "/Applications"),
        URL(filePath: "/System/Applications"),
        URL.homeDirectory.appending(path: "Applications"),
    ]
    private static let finder = URL(filePath: "/System/Library/CoreServices/Finder.app")
    private static let folderDepth = 2
    private static let watchLatencySeconds = 1.0

    private(set) var apps: [InstalledApp] = []
    @ObservationIgnored private var stream: FSEventStreamRef?

    func start() {
        reload()
        watch()
    }

    func matches(_ query: String) -> [InstalledApp] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        return apps
            .compactMap { app in app.match(for: query).map { (app: app, match: $0) } }
            .sorted { ($0.match.rawValue, $0.app.name.localizedLowercase) < ($1.match.rawValue, $1.app.name.localizedLowercase) }
            .map(\.app)
    }

    private func reload() {
        let urls = Set(Self.folders.flatMap(Self.apps(in:)) + [Self.finder])
        apps = urls.map(InstalledApp.init(url:)).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func watch() {
        let paths = Self.folders.map(\.path) as CFArray
        let created = FSEventStreamCreate(
            nil,
            { _, _, _, _, _, _ in MainActor.assumeIsolated { AppCatalog.shared.reload() } },
            nil,
            paths,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            Self.watchLatencySeconds,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagNone)
        )
        guard let created else { return }
        FSEventStreamSetDispatchQueue(created, .main)
        FSEventStreamStart(created)
        stream = created
    }

    private static func apps(in folder: URL) -> [URL] {
        guard let items = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: nil, options: .skipsPackageDescendants) else { return [] }
        var apps: [URL] = []
        for case let url as URL in items {
            if items.level >= folderDepth { items.skipDescendants() }
            if url.pathExtension == "app" { apps.append(url) }
        }
        return apps
    }
}
