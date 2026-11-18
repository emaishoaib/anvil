import Foundation

/// Whether Claude Code stopped because it is too old for the options Anvil starts it with, read from the errors it printed. An older Claude Code refuses an option it does not know yet, and says so.
public enum OutdatedClaude {
    public static func isOutdated(printing errors: String) -> Bool {
        errors.contains("unknown option")
    }
}
