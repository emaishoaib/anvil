import AppKit

enum SystemSounds {
    private static let folders = [
        URL(filePath: "/System/Library/Sounds"),
        URL(filePath: "/Library/Sounds"),
        FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Sounds"),
    ]

    static var names: [String] {
        let files = folders.flatMap { (try? FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil)) ?? [] }
        return Set(files.map { $0.deletingPathExtension().lastPathComponent }).sorted()
    }

    static func play(_ name: String) {
        NSSound(named: name)?.play()
    }
}
