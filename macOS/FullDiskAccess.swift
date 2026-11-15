import AppKit

/// Whether Anvil can read every app's files in the Library, which only Full Disk Access allows. Without it, macOS keeps other apps' containers from Anvil, so some leftovers cannot be found or moved.
///
/// macOS has no call that answers this directly, so the check opens a file that only Full Disk Access unlocks: the Mac's system-wide privacy database. The one in the user's own Library is not used, because it does not exist on every Mac.
nonisolated enum FullDiskAccess {
    private static let protectedFile = URL(filePath: "/Library/Application Support/com.apple.TCC/TCC.db")
    private static let settingsPane = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")

    static var isGranted: Bool {
        guard let handle = try? FileHandle(forReadingFrom: protectedFile) else { return false }
        try? handle.close()
        return true
    }

    static func openSettings() {
        guard let settingsPane else { return }
        NSWorkspace.shared.open(settingsPane)
    }
}
