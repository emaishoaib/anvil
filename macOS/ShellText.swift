import ShellKit

/// One of the two free-form parts of the shell setup, each edited as a block of zsh in its own form.
enum ShellText: CaseIterable {
    case startupLines
    case prompt

    var title: String {
        switch self {
        case .startupLines: "Startup Lines"
        case .prompt: "Prompt"
        }
    }

    var hint: String {
        switch self {
        case .startupLines: "Lines of zsh run first when a shell starts, before the aliases."
        case .prompt: "Lines of zsh run last, after the aliases, usually to set PROMPT."
        }
    }

    var current: String {
        switch self {
        case .startupLines: ShellLibrary.shared.setup.startupLines
        case .prompt: ShellLibrary.shared.setup.prompt
        }
    }

    func save(_ text: String) {
        switch self {
        case .startupLines: ShellLibrary.shared.setStartupLines(text)
        case .prompt: ShellLibrary.shared.setPrompt(text)
        }
    }
}
