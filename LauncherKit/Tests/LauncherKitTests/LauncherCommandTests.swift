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
}
