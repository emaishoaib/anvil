import Foundation
import LauncherKit
import ShellKit

/// The Shell tool's rows in the search bar: a switch for loading the setup in new shells, a row each for the startup lines and the prompt, showing their first line, then a row to add an alias, then a row per alias showing its command, which deletes it. While the shell file can't be read, its problem shows as a warning row and the other rows can't be used.
enum ShellCatalog {
    private static let aliasesName = "Aliases"

    static func settings() -> [Setting] {
        let library = ShellLibrary.shared
        let isBroken = library.loadProblem != nil
        let aliases = library.setup.aliases
        return problem + [loadInNewShells] + ShellText.allCases.map { row(for: $0, isDisabled: isBroken) } + Setting.subgroup(aliasesName,
            [addAlias(isDisabled: isBroken)]
                + (aliases.isEmpty && !isBroken ? [.info("No aliases yet", id: "shell.aliases.empty", toolName: Tool.shell.name)] : [])
                + aliases.map { row(for: $0, isDisabled: isBroken) }
        )
    }

    private static var loadInNewShells: Setting {
        Setting(
            entry: SettingEntry(id: "shell.loadInNewShells", title: "Load in New Shells", toolName: Tool.shell.name, keywords: ["zshrc"]),
            subtitle: "Adds a block to ~/.zshrc that loads Anvil's shell file.",
            row: .toggle(isOn: ShellLoading.isOn, set: ShellLoading.set)
        )
    }

    private static func row(for text: ShellText, isDisabled: Bool) -> Setting {
        .action(text.title, id: "shell.\(text)", toolName: Tool.shell.name, subtitle: firstLine(of: text.current), actionTitle: "Edit", isDisabled: isDisabled) {
            SearchBar.shared.showShellTextForm(text)
            return nil
        }
    }

    private static func firstLine(of text: String) -> String {
        text.split(separator: "\n").first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.map(String.init) ?? "Nothing yet"
    }

    private static func addAlias(isDisabled: Bool) -> Setting {
        .action("Add Alias", id: "shell.aliases.add", toolName: Tool.shell.name, isDisabled: isDisabled) {
            SearchBar.shared.showAliasForm()
            return nil
        }
    }

    private static var problem: [Setting] {
        guard let problem = ShellLibrary.shared.loadProblem else { return [] }
        var row = Setting.info("Shell setup can't be changed", id: "shell.problem", toolName: Tool.shell.name)
        row.warning = problem
        return [row]
    }

    private static func row(for alias: Alias, isDisabled: Bool) -> Setting {
        .action(alias.name, id: "shell.alias.\(alias.id)", toolName: Tool.shell.name, subtitle: alias.command, actionTitle: "Delete Alias", isDisabled: isDisabled) {
            ShellLibrary.shared.delete(alias)
            return nil
        }
    }
}
