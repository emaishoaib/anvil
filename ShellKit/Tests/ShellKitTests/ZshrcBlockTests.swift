import Testing
@testable import ShellKit

struct ZshrcBlockTests {
    private static let path = "/Users/me/Library/Application Support/com.mashoaib.anvil/shell.zsh"
    private static let block = """
        # >>> anvil >>>
        [ -f "\(path)" ] && source "\(path)"
        # <<< anvil <<<
        """

    @Test func addingPutsTheBlockAfterABlankLineAtTheEnd() {
        let zshrc = ZshrcBlock.adding(sourcing: Self.path, to: "export A=1\n")
        #expect(zshrc == "export A=1\n\n" + Self.block + "\n")
    }

    @Test func addingToAFileWithoutAFinalNewlineStillLeavesABlankLine() {
        let zshrc = ZshrcBlock.adding(sourcing: Self.path, to: "export A=1")
        #expect(zshrc == "export A=1\n\n" + Self.block + "\n")
    }

    @Test func addingToAnEmptyFileWritesOnlyTheBlock() {
        #expect(ZshrcBlock.adding(sourcing: Self.path, to: "") == Self.block + "\n")
    }

    @Test func addingAgainReplacesTheBlockInsteadOfRepeatingIt() {
        let old = ZshrcBlock.adding(sourcing: "/old/shell.zsh", to: "export A=1\n")
        let zshrc = ZshrcBlock.adding(sourcing: Self.path, to: old + "export B=2\n")
        #expect(zshrc == "export A=1\nexport B=2\n\n" + Self.block + "\n")
    }

    @Test func removingGivesBackTheFileAsItWasBeforeAdding() {
        let original = "export A=1\n"
        #expect(ZshrcBlock.removing(from: ZshrcBlock.adding(sourcing: Self.path, to: original)) == original)
    }

    @Test func removingLeavesAFileWithoutABlockAlone() {
        let zshrc = "export A=1\n\n# >>> workshop >>>\nsource x\n# <<< workshop <<<\n"
        #expect(ZshrcBlock.removing(from: zshrc) == zshrc)
    }

    @Test func theBlockIsPresentOnlyWhenItSourcesTheSamePath() {
        let zshrc = ZshrcBlock.adding(sourcing: Self.path, to: "export A=1\n")
        #expect(ZshrcBlock.isPresent(sourcing: Self.path, in: zshrc))
        #expect(!ZshrcBlock.isPresent(sourcing: "/old/shell.zsh", in: zshrc))
    }
}
