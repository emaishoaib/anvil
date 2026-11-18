import Foundation

/// Everything Anvil puts in the shell: lines run first when a shell starts, the aliases, and the lines that set the prompt. It turns them into the text of the zsh file that `~/.zshrc` loads.
public struct ShellSetup: Equatable, Codable, Sendable {
    private static let header = "# Written by Anvil from its Shell settings. Changes made here are overwritten."

    public private(set) var aliases: [Alias]
    public var startupLines: String
    public var prompt: String

    public init(aliases: [Alias] = [], startupLines: String = "", prompt: String = "") {
        self.aliases = aliases
        self.startupLines = startupLines
        self.prompt = prompt
    }

    public mutating func save(_ alias: Alias) {
        if let index = aliases.firstIndex(where: { $0.id == alias.id }) {
            aliases[index] = alias
        } else {
            aliases.append(alias)
        }
    }

    public mutating func delete(_ alias: Alias) {
        aliases.removeAll { $0.id == alias.id }
    }

    public var zsh: String {
        let sections = [startupLines, aliases.map(\.zshLine).joined(separator: "\n"), prompt]
            .map { $0.trimmingCharacters(in: .newlines) }
            .filter { !$0.isEmpty }
        return ([Self.header] + sections).joined(separator: "\n\n") + "\n"
    }
}
