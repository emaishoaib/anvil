import Foundation

/// Where the `claude` command-line tool is installed, if it is, and how to run it. Anvil looks in the folders its installers use, because an app opened from Finder does not get the shell's PATH. For the same reason, every run gets a PATH with those folders, since the tools Claude runs, such as `git`, need it.
nonisolated enum ClaudeCommand {
    private static let home = FileManager.default.homeDirectoryForCurrentUser
    private static let searchPath = ["~/.local/bin", "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin"]

    private static let candidates = [
        home.appending(path: ".local/bin/claude"),
        home.appending(path: ".claude/local/claude"),
        URL(filePath: "/opt/homebrew/bin/claude"),
        URL(filePath: "/usr/local/bin/claude"),
    ]

    static var url: URL? {
        candidates.first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }

    static var environment: [String: String] {
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = searchPath.map { $0.replacingOccurrences(of: "~", with: home.path) }.joined(separator: ":")
        return environment
    }

    /// A `claude` command ready to run with the given arguments, or nothing when Claude Code is not installed. Its input stays open without ever being written to, so a command that waits for input keeps waiting instead of giving up.
    static func process(_ arguments: [String]) -> Process? {
        guard let url else { return nil }
        let process = Process()
        process.executableURL = url
        process.arguments = arguments
        process.environment = environment
        process.standardInput = Pipe()
        process.standardError = FileHandle.nullDevice
        return process
    }
}

extension Process {
    /// Runs the command and waits for it to end, giving back what it printed, or nothing when it could not start.
    nonisolated func output() async -> Data? {
        let pipe = Pipe()
        standardOutput = pipe
        return await withCheckedContinuation { continuation in
            terminationHandler = { _ in continuation.resume(returning: pipe.fileHandleForReading.readDataToEndOfFile()) }
            guard (try? run()) != nil else {
                terminationHandler = nil
                return continuation.resume(returning: nil)
            }
        }
    }
}
