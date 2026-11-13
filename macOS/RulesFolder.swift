import AppKit
import CoreServices
import Observation

@Observable final class RulesFolder {
    static let shared = RulesFolder()

    private static let watchLatencySeconds = 0.5

    private(set) var url = RuleStorage.folder
    @ObservationIgnored private var stream: FSEventStreamRef?

    var displayPath: String {
        url.map { ($0.path as NSString).abbreviatingWithTildeInPath } ?? "Anvil's settings"
    }

    func start() {
        watch()
    }

    func choose() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.message = "Choose the folder that holds rules.json, key-swaps.json and mouse.json"
        guard panel.runModal() == .OK, let chosen = panel.url else { return }
        use(chosen)
    }

    func useSettings() {
        use(nil)
    }

    private func use(_ folder: URL?) {
        RuleStorage.folder = folder
        url = folder
        reload()
        watch()
    }

    func reload() {
        RuleLibrary.shared.reload()
        KeySwapLibrary.shared.reload()
        MouseSettingsLibrary.shared.reload()
    }

    private func watch() {
        if let stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
        stream = nil
        guard let url else { return }
        let created = FSEventStreamCreate(
            nil,
            { _, _, _, _, _, _ in MainActor.assumeIsolated { RulesFolder.shared.reload() } },
            nil,
            [url.path] as CFArray,
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
