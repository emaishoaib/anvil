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

    @Test func enterAIModeMatchesItsKeyword() {
        #expect(LauncherCommand.enterAIMode.match(for: "ai") == .namePrefix)
    }

    @Test func enterAIModeMatchesItsNameAndLaterWords() {
        #expect(LauncherCommand.enterAIMode.match(for: "enter") == .namePrefix)
        #expect(LauncherCommand.enterAIMode.match(for: "mode") == .wordPrefix)
    }

    @Test func settingsMatchesItsKeyword() {
        #expect(LauncherCommand.settings.match(for: "set") == .namePrefix)
        #expect(LauncherCommand.settings.match(for: "settings") == .namePrefix)
    }
}
