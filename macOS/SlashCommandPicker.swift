import ClaudeKit
import Foundation
import Observation

/// The skills and commands offered while a chat prompt is a slash followed by part of a name, with one of them selected. Names starting with what was typed come first, then names holding it anywhere. The list is read afresh each time a slash is typed, so a skill added since shows up, and once dismissed it stays away until the prompt changes.
@Observable final class SlashCommandPicker {
    private(set) var matches: [SlashCommand] = []
    private(set) var selected = 0
    @ObservationIgnored private var available: (folder: URL, commands: [SlashCommand])?
    @ObservationIgnored private var dismissedPrompt: String?

    var isShowing: Bool { !matches.isEmpty }

    var selectedCommand: SlashCommand? {
        matches.indices.contains(selected) ? matches[selected] : nil
    }

    func update(for prompt: String, in folder: URL) {
        selected = 0
        guard prompt != dismissedPrompt, let typed = Self.typedName(in: prompt) else {
            matches = []
            return
        }
        dismissedPrompt = nil
        if typed.isEmpty { available = nil }
        let commands = commands(in: folder)
        let starting = commands.filter { $0.name.lowercased().hasPrefix(typed) }
        let holding = commands.filter { !$0.name.lowercased().hasPrefix(typed) && $0.name.lowercased().contains(typed) }
        matches = starting + holding
    }

    func moveSelection(by offset: Int) {
        guard !matches.isEmpty else { return }
        selected = min(max(selected + offset, 0), matches.count - 1)
    }

    func select(_ index: Int) {
        guard matches.indices.contains(index) else { return }
        selected = index
    }

    func dismiss(prompt: String) {
        dismissedPrompt = prompt
        matches = []
    }

    private func commands(in folder: URL) -> [SlashCommand] {
        if let available, available.folder == folder { return available.commands }
        let commands = SlashCommandFiles.available(in: folder)
        available = (folder, commands)
        return commands
    }

    private static func typedName(in prompt: String) -> String? {
        guard prompt.hasPrefix("/") else { return nil }
        let name = prompt.dropFirst()
        guard !name.contains(where: \.isWhitespace) else { return nil }
        return name.lowercased()
    }
}
