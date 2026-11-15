import CleanerKit
import Foundation
import Observation

/// The size of each installed app together with the files the walk of the Mac found for it, measured one app at a time away from the main thread once the walk is done. An app's own bundle is kept while Anvil runs and measured again only when it has changed since, such as after an update. Its found files are measured afresh after every walk, because they change as the app runs. Asking for a new list stops measuring the old one and forgets the sizes from the walk before.
@Observable final class AppSizes {
    static let shared = AppSizes()

    private struct BundleMeasurement {
        let modified: Date?
        let bytes: Int64
    }

    private var totals: [URL: Int64] = [:]
    @ObservationIgnored private var bundles: [URL: BundleMeasurement] = [:]
    @ObservationIgnored private var measuring: Task<Void, Never>?

    func bytes(of app: URL) -> Int64? {
        totals[app]
    }

    func measure(_ apps: [URL], with index: LeftoverIndex) {
        measuring?.cancel()
        totals = [:]
        measuring = Task {
            for app in apps {
                guard !Task.isCancelled else { return }
                let bundleBytes = await bundleBytes(of: app)
                let finds = index.finds(forAppAt: app)
                let findBytes = await Task.detached { finds.reduce(0) { $0 + DiskSize.bytes(at: $1) } }.value
                totals[app] = bundleBytes + findBytes
            }
        }
    }

    private func bundleBytes(of app: URL) async -> Int64 {
        let modified = Self.modificationDate(of: app)
        if let known = bundles[app], known.modified == modified { return known.bytes }
        let bytes = await Task.detached { DiskSize.bytes(at: app) }.value
        bundles[app] = BundleMeasurement(modified: modified, bytes: bytes)
        return bytes
    }

    private static func modificationDate(of app: URL) -> Date? {
        try? app.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
    }
}
