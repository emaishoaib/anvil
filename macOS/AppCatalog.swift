import CoreServices
import Foundation
import LauncherKit
import Observation

@Observable final class AppCatalog {
    static let shared = AppCatalog()

    private static let folders = [
        URL(filePath: "/Applications"),
        URL(filePath: "/System/Applications"),
        URL.homeDirectory.appending(path: "Applications"),
    ]
    private static let finder = URL(filePath: "/System/Library/CoreServices/Finder.app")
    private static let watchLatencySeconds = 1.0

    private(set) var apps: [InstalledApp] = []
    @ObservationIgnored private var stream: FSEventStreamRef?

    func start() {
        reload()
        watch()
    }

    /// Scans the app folders again. The folder watcher does this on its own after a short delay, so call it only when the list must be current right away, such as just after an app has gone to the Trash.
    func reload() {
        let urls = Set(Self.folders.flatMap { AppScanner.apps(in: $0) } + [Self.finder])
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
}
