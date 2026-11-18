import LauncherKit
import ShellKit

/// The Shell tool's rows in the search bar: a row per alias showing its command, which deletes it. While the shell file can't be read, its problem shows as a warning row and the other rows can't be used.
enum ShellCatalog {
    private static let aliasesName = "Aliases"

    static func settings() -> [Setting] {
        let library = ShellLibrary.shared
        let isBroken = library.loadProblem != nil
        let aliases = library.setup.aliases
        return problem + Setting.subgroup(aliasesName,
            (aliases.isEmpty && !isBroken ? [.info("No aliases yet", id: "shell.aliases.empty", toolName: Tool.shell.name)] : [])
                + aliases.map { row(for: $0, isDisabled: isBroken) }
        )
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
