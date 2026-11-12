import AppKit

enum Accessibility {
    private static let trustCheckInterval = Duration.seconds(1)

    static func waitUntilTrusted() async {
        guard !AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary) else { return }
        NSApp.setActivationPolicy(.regular)
        while !AXIsProcessTrusted() {
            try? await Task.sleep(for: trustCheckInterval)
        }
        NSApp.setActivationPolicy(.accessory)
    }
}
