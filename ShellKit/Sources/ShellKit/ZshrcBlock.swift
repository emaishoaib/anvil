import Foundation

/// The marked block Anvil keeps in `~/.zshrc` to load its zsh file. The markers let it find, replace and remove its own lines without touching anything else in the file, the same way workshop's `setup.sh` keeps its block.
public enum ZshrcBlock {
    static let start = "# >>> anvil >>>"
    static let end = "# <<< anvil <<<"

    /// Puts the block at the end of the file, replacing any block already there, such as one pointing at an older path.
    public static func adding(sourcing path: String, to zshrc: String) -> String {
        let kept = removing(from: zshrc)
        guard !kept.isEmpty else { return block(sourcing: path) + "\n" }
        return (kept.hasSuffix("\n") ? kept : kept + "\n") + "\n" + block(sourcing: path) + "\n"
    }

    /// Takes out every block, along with the blank line in front of each one.
    public static func removing(from zshrc: String) -> String {
        var lines = zshrc.components(separatedBy: "\n")
        while let first = lines.firstIndex(of: start), let last = lines[first...].firstIndex(of: end) {
            let from = first > 0 && lines[first - 1].isEmpty ? first - 1 : first
            lines.removeSubrange(from...last)
        }
        return lines.joined(separator: "\n")
    }

    static func block(sourcing path: String) -> String {
        [start, #"[ -f "\#(path)" ] && source "\#(path)""#, end].joined(separator: "\n")
    }
}
