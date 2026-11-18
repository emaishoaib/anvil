import Testing
@testable import ShellKit

struct AliasTests {
    @Test(arguments: ["czsh", "git-st", "my_alias", "ls.all", "l2"])
    func aNameOfLettersDigitsDashesUnderscoresAndDotsIsComplete(name: String) {
        #expect(Alias(name: name, command: "ls").isComplete)
    }

    @Test(arguments: ["", "two words", "a=b", "it's", "$x", "a;b"])
    func aNameWithAnythingElseIsNotComplete(name: String) {
        #expect(!Alias(name: name, command: "ls").isComplete)
    }

    @Test(arguments: ["", "   ", "\n"])
    func aBlankCommandIsNotComplete(command: String) {
        #expect(!Alias(name: "ll", command: command).isComplete)
    }
}
