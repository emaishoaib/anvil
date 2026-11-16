import Testing
@testable import LauncherKit

struct LauncherCommandTests {
    @Test func defineWordMatchesFromItsFirstLetter() {
        #expect(LauncherCommand.defineWord.match(for: "d") == .namePrefix)
        #expect(LauncherCommand.defineWord.match(for: "def") == .namePrefix)
    }

    @Test func defineWordMatchesItsSecondWord() {
        #expect(LauncherCommand.defineWord.match(for: "word") == .wordPrefix)
    }

    @Test func defineWordMatchesItsWholeKeyword() {
        #expect(LauncherCommand.defineWord.match(for: "define") == .namePrefix)
    }

    @Test func otherTextDoesNotMatchDefineWord() {
        #expect(LauncherCommand.defineWord.match(for: "safari") == nil)
    }

    @Test func createQuickLinkMatchesItsNameAndKeyword() {
        #expect(LauncherCommand.createQuickLink.match(for: "cre") == .namePrefix)
        #expect(LauncherCommand.createQuickLink.match(for: "quick") == .wordPrefix)
        #expect(LauncherCommand.createQuickLink.match(for: "link") == .namePrefix)
    }

    @Test func uninstallAppMatchesItsNameAndKeyword() {
        #expect(LauncherCommand.uninstallApp.match(for: "uninstall") == .namePrefix)
        #expect(LauncherCommand.uninstallApp.match(for: "app") == .wordPrefix)
    }

    @Test func askClaudeMatchesItsWholeName() {
        #expect(LauncherCommand.askClaude.match(for: "ask") == .namePrefix)
        #expect(LauncherCommand.askClaude.match(for: "ask claude") == .namePrefix)
    }

    @Test func askClaudeMatchesClaudeOnlyAsALaterWordSoTheClaudeAppComesFirst() {
        #expect(LauncherCommand.askClaude.match(for: "claude") == .wordPrefix)
    }

    @Test func settingsMatchesItsKeyword() {
        #expect(LauncherCommand.settings.match(for: "set") == .namePrefix)
        #expect(LauncherCommand.settings.match(for: "settings") == .namePrefix)
    }
}
