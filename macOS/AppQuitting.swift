import AppKit

/// Quits an app before it is uninstalled, so it cannot write its files again after they have gone to the Trash.
enum AppQuitting {
    private static let timeout = Duration.seconds(5)
    private static let checkInterval = Duration.milliseconds(100)

    /// Asks every running copy of the app at the URL to quit, then waits for them. Gives false when one is still running once the time is up, such as when it is waiting for a document to be saved.
    static func quit(appAt url: URL) async -> Bool {
        let running = NSWorkspace.shared.runningApplications.filter { $0.bundleURL?.standardizedFileURL.path == url.standardizedFileURL.path }
        running.forEach { $0.terminate() }
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        while running.contains(where: { !$0.isTerminated }) {
            guard clock.now < deadline else { return false }
            try? await Task.sleep(for: checkInterval)
        }
        return true
    }
}
