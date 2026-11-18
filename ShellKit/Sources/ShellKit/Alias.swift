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

    var zshLine: String {
        "alias \(name)='\(command.replacing("'", with: #"'\''"#))'"
    }
}
