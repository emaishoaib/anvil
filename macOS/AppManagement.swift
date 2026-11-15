import AppKit

/// The App Management permission, which macOS requires before Anvil can move another developer's app to the Trash. Finder has it from the start, but other apps must be allowed in Privacy & Security.
///
/// macOS has no call that says whether it is granted, so Anvil only learns it is missing when moving an app to the Trash is refused.
nonisolated enum AppManagement {
    private static let settingsPane = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles")

    static func openSettings() {
        guard let settingsPane else { return }
        NSWorkspace.shared.open(settingsPane)
    }
}
