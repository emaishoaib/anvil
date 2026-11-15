import CleanerKit
import Foundation
import Observation

/// The sizes of installed apps, measured one at a time away from the main thread and kept while Anvil runs. An app is measured again when it has changed since, such as after an update. Asking for a new list stops measuring the old one.
@Observable final class AppSizes {
    static let shared = AppSizes()

    private struct Measurement {
        let modified: Date?
        let bytes: Int64
    }

    private var measurements: [URL: Measurement] = [:]
    @ObservationIgnored private var measuring: Task<Void, Never>?

    func bytes(of app: URL) -> Int64? {
        measurements[app]?.bytes
    }

    func measure(_ apps: [URL]) {
        measuring?.cancel()
        measuring = Task {
            for app in apps {
                guard !Task.isCancelled else { return }
                let modified = Self.modificationDate(of: app)
                if let known = measurements[app], known.modified == modified { continue }
                let bytes = await Task.detached { DiskSize.bytes(at: app) }.value
                measurements[app] = Measurement(modified: modified, bytes: bytes)
            }
        }
    }

    private static func modificationDate(of app: URL) -> Date? {
        try? app.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
    }
}
