import AppKit

enum Accessibility {
    private static let trustCheckInterval = Duration.seconds(1)

    static func waitUntilTrusted() async {
        guard !AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary) else { return }
        while !AXIsProcessTrusted() {
            try? await Task.sleep(for: trustCheckInterval)
        }
    }
}
