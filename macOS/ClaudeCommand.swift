import Foundation

/// Where the `claude` command-line tool is installed, if it is. Anvil looks in the folders its installers use, because an app opened from Finder does not get the shell's PATH.
nonisolated enum ClaudeCommand {
    private static let home = FileManager.default.homeDirectoryForCurrentUser

    private static let candidates = [
        home.appending(path: ".local/bin/claude"),
        home.appending(path: ".claude/local/claude"),
        URL(filePath: "/opt/homebrew/bin/claude"),
        URL(filePath: "/usr/local/bin/claude"),
    ]

    static var url: URL? {
        candidates.first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }
}
