import ClaudeKit
import Foundation

/// The skills and commands a chat can run with a slash: the user's own under `~/.claude`, then the chat folder's under its `.claude`. Skills are folders holding a `SKILL.md`, and commands are Markdown files in the commands folder. When two share a name the user's own is kept, and the rest are listed by name.
nonisolated enum SlashCommandFiles {
    private static let userFolder = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".claude")

    static func available(in folder: URL) -> [SlashCommand] {
        let roots = [userFolder, folder.appending(path: ".claude")]
        let found = roots.flatMap { skills(in: $0) + commands(in: $0) }
        var seen: Set<String> = []
        return found
            .filter { seen.insert($0.name).inserted }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private static func skills(in root: URL) -> [SlashCommand] {
        contents(of: root.appending(path: "skills")).compactMap { skillFolder in
            guard let contents = try? String(contentsOf: skillFolder.appending(path: "SKILL.md"), encoding: .utf8) else { return nil }
            return SlashCommand.skill(contents, folderName: skillFolder.lastPathComponent)
        }
    }

    private static func commands(in root: URL) -> [SlashCommand] {
        contents(of: root.appending(path: "commands"))
            .filter { $0.pathExtension == "md" }
            .compactMap { file in
                guard let contents = try? String(contentsOf: file, encoding: .utf8) else { return nil }
                return SlashCommand.command(contents, fileName: file.deletingPathExtension().lastPathComponent)
            }
    }

    private static func contents(of folder: URL) -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
    }
}
