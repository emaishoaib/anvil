import Foundation

/// Takes a screenshot of the part of the screen you drag over, using the Mac's own screenshot tool, so it looks and works as the system's shortcut does: Space switches to picking a window and Escape cancels. The picture is read into memory as PNG data and its file removed straight away. Nothing comes back when it was cancelled.
nonisolated enum ScreenCapture {
    private static let tool = URL(filePath: "/usr/sbin/screencapture")

    static func dragged() async -> Data? {
        let file = FileManager.default.temporaryDirectory.appending(path: "Anvil Screenshot \(UUID().uuidString).png")
        defer { try? FileManager.default.removeItem(at: file) }
        let process = Process()
        process.executableURL = tool
        process.arguments = ["-i", file.path]
        await withCheckedContinuation { (finished: CheckedContinuation<Void, Never>) in
            process.terminationHandler = { @Sendable _ in finished.resume() }
            do {
                try process.run()
            } catch {
                process.terminationHandler = nil
                finished.resume()
            }
        }
        return try? Data(contentsOf: file)
    }
}
