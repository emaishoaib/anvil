import Foundation

/// A skill or command that can be run by typing a slash and its name at the start of a prompt, with a few words on what it does.
public struct SlashCommand: Equatable, Sendable {
    public let name: String
    public let description: String

    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }

    /// A skill, read from its `SKILL.md`. It takes the name in its fields, or its folder's name when it has none, and a skill marked as not for the user to run has no slash command.
    public static func skill(_ contents: String, folderName: String) -> SlashCommand? {
        let fields = FrontMatter.fields(in: contents)
        guard fields["user-invocable"] != "false" else { return nil }
        let name = fields["name"].flatMap { $0.isEmpty ? nil : $0 } ?? folderName
        return SlashCommand(name: name, description: fields["description"] ?? "")
    }

    /// A command, read from its Markdown file and named after it. It is described by the description in its fields, or else by the first line of what follows them, without any heading marks.
    public static func command(_ contents: String, fileName: String) -> SlashCommand {
        if let description = FrontMatter.fields(in: contents)["description"], !description.isEmpty {
            return SlashCommand(name: fileName, description: description)
        }
        return SlashCommand(name: fileName, description: firstLine(of: FrontMatter.body(of: contents)))
    }

    private static func firstLine(of text: String) -> String {
        let line = text.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty } ?? ""
        return String(line.drop { $0 == "#" }).trimmingCharacters(in: .whitespaces)
    }
}
