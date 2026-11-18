import Foundation
import ShellKit

/// Adds or removes the block in `~/.zshrc` that loads Anvil's zsh file, as the Shell tool is turned on or off. A `~/.zshrc` that is a link is followed, so the file it points at is changed, not the link. A file that exists but can't be read is never written over.
enum ShellLoading {
    private static let zshrc = URL.homeDirectory.appending(path: ".zshrc")

    static func set(_ isOn: Bool) {
        guard let contents = read() else { return }
        let updated = isOn ? ZshrcBlock.adding(sourcing: ShellLibrary.zshFile.path, to: contents) : ZshrcBlock.removing(from: contents)
        try? Data(updated.utf8).write(to: zshrc.resolvingSymlinksInPath(), options: .atomic)
    }

    private static func read() -> String? {
        let file = zshrc.resolvingSymlinksInPath()
        guard FileManager.default.fileExists(atPath: file.path) else { return "" }
        return try? String(contentsOf: file, encoding: .utf8)
    }
}
