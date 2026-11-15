import LauncherKit
import RulesKit

/// The key swaps' rows in the search bar: a row to add one at the top, then a row per swap that deletes it. While the key swaps file can't be read, its problem shows as a warning row and the other rows can't be used.
enum KeySwapsCatalog {
    static let explanation = "Swaps two keys on the Mac's built-in keyboard. External keyboards are left alone."

    static func settings() -> [Setting] {
        let library = KeySwapLibrary.shared
        let isBroken = library.loadProblem != nil
        return problem + [addKeySwap(isDisabled: isBroken)] + library.swaps.map { row(for: $0, isDisabled: isBroken) }
    }

    private static var problem: [Setting] {
        guard let problem = KeySwapLibrary.shared.loadProblem else { return [] }
        var row = Setting.info("Key swaps can't be changed", id: "keySwaps.problem", toolName: Tool.rules.name)
        row.warning = problem
        return [row]
    }

    private static func addKeySwap(isDisabled: Bool) -> Setting {
        .action("Add Key Swap", id: "keySwaps.add", toolName: Tool.rules.name, subtitle: explanation, isDisabled: isDisabled) {
            SearchBar.shared.showKeySwapForm()
            return nil
        }
    }

    private static func row(for swap: KeySwap, isDisabled: Bool) -> Setting {
        .action("Swap \(HIDKeys.name(for: swap.first)) and \(HIDKeys.name(for: swap.second))", id: "keySwap.\(swap.id)", toolName: Tool.rules.name, actionTitle: "Delete Key Swap", isDisabled: isDisabled) {
            KeySwapLibrary.shared.delete(swap)
            return nil
        }
    }
}
