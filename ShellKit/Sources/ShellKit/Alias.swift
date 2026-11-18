import Foundation

/// A short name typed in the shell that runs a longer command in its place.
public struct Alias: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var name: String
    public var command: String

    public init(id: UUID = UUID(), name: String, command: String) {
        self.id = id
        self.name = name
        self.command = command
    }

    /// Whether the alias can be saved: a name of letters, digits, dashes, underscores and dots, and a command that isn't blank.
    public var isComplete: Bool {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
        return !name.isEmpty
            && name.unicodeScalars.allSatisfy(allowed.contains)
            && !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var zshLine: String {
        "alias \(name)='\(command.replacing("'", with: #"'\''"#))'"
    }
}
