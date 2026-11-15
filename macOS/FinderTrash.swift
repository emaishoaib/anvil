import Foundation

/// Moves items to the Trash through Finder, which asks for an admin password when an item belongs to root, as apps from the Mac App Store do. Anvil cannot ask for that password itself. All the items go in one request, so the password is asked for once. The first time, macOS also asks to let Anvil control Finder.
enum FinderTrash {
    struct Failure: LocalizedError {
        var errorDescription: String? { "Finder couldn't move it to the Trash" }
    }

    private static let script = [
        "on run itemPaths",
        "set targets to {}",
        "repeat with itemPath in itemPaths",
        "set end of targets to (POSIX file (contents of itemPath)) as alias",
        "end repeat",
        "with timeout of 600 seconds",
        "tell application \"Finder\" to delete targets",
        "end timeout",
        "end run",
    ]

    static func moveToTrash(_ urls: [URL]) async throws {
        let succeeded = await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/osascript")
            process.arguments = script.flatMap { ["-e", $0] } + urls.map { $0.path(percentEncoded: false) }
            process.terminationHandler = { continuation.resume(returning: $0.terminationStatus == 0) }
            do {
                try process.run()
            } catch {
                continuation.resume(returning: false)
            }
        }
        guard succeeded else { throw Failure() }
    }
}
