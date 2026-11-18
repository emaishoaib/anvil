import Testing
@testable import ShellKit

struct ShellSetupTests {
    private static let header = "# Written by Anvil from its Shell settings. Changes made here are overwritten."

    @Test func anEmptySetupWritesOnlyTheHeader() {
        #expect(ShellSetup().zsh == Self.header + "\n")
    }

    @Test func startupLinesComeFirstThenAliasesThenThePrompt() {
        let setup = ShellSetup(
            aliases: [Alias(name: "czsh", command: "code ~/.zshrc"), Alias(name: "rzsh", command: "source ~/.zshrc")],
            startupLines: "[[ -o interactive ]] && unset GIT_EDITOR",
            prompt: #"PROMPT="%F{green}%n@%m %1~ %#%f ""#
        )
        #expect(setup.zsh == """
            \(Self.header)

            [[ -o interactive ]] && unset GIT_EDITOR

            alias czsh='code ~/.zshrc'
            alias rzsh='source ~/.zshrc'

            PROMPT="%F{green}%n@%m %1~ %#%f "

            """)
    }

    @Test func emptySectionsAndTheirBlankLinesAreLeftOut() {
        let setup = ShellSetup(startupLines: "\n\nexport A=1\n\n", prompt: "\n")
        #expect(setup.zsh == Self.header + "\n\nexport A=1\n")
    }

    @Test func singleQuotesInACommandAreEscapedForZsh() {
        let alias = Alias(name: "say", command: "echo 'hi'")
        #expect(alias.zshLine == #"alias say='echo '\''hi'\'''"#)
    }

    @Test func savingAnAliasWithAKnownIDReplacesIt() {
        let alias = Alias(name: "ll", command: "ls -l")
        var setup = ShellSetup(aliases: [alias])
        var renamed = alias
        renamed.name = "la"
        setup.save(renamed)
        #expect(setup.aliases == [renamed])
    }

    @Test func savingANewAliasAddsItToTheEnd() {
        let first = Alias(name: "ll", command: "ls -l")
        let second = Alias(name: "la", command: "ls -a")
        var setup = ShellSetup(aliases: [first])
        setup.save(second)
        #expect(setup.aliases == [first, second])
    }

    @Test func deletingAnAliasRemovesOnlyThatOne() {
        let first = Alias(name: "ll", command: "ls -l")
        let second = Alias(name: "la", command: "ls -a")
        var setup = ShellSetup(aliases: [first, second])
        setup.delete(first)
        #expect(setup.aliases == [second])
    }
}
