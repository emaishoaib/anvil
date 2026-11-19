import Testing
@testable import ClaudeKit

struct SlashCommandTests {
    @Test func aSkillTakesItsNameAndDescription() {
        let skill = SlashCommand.skill("---\nname: trace\ndescription: Traces a flow.\n---\nBody", folderName: "trace-folder")
        #expect(skill == SlashCommand(name: "trace", description: "Traces a flow."))
    }

    @Test func aSkillWithoutANameTakesItsFolders() {
        #expect(SlashCommand.skill("---\ndescription: Captures notes.\n---", folderName: "capture")?.name == "capture")
    }

    @Test func aSkillNotForTheUserHasNoSlashCommand() {
        #expect(SlashCommand.skill("---\nname: helper\nuser-invocable: false\n---", folderName: "helper") == nil)
    }

    @Test func aCommandIsNamedAfterItsFile() {
        let command = SlashCommand.command("---\ndescription: Ships it.\n---\nDeploy the app.", fileName: "deploy")
        #expect(command == SlashCommand(name: "deploy", description: "Ships it."))
    }

    @Test func aCommandWithoutADescriptionIsDescribedByItsFirstLine() {
        #expect(SlashCommand.command("\n# Review the branch\nThen report.", fileName: "review").description == "Review the branch")
    }

    @Test func aCommandWithFieldsButNoDescriptionIsDescribedByItsBody() {
        #expect(SlashCommand.command("---\nmodel: opus\n---\nCheck the logs.", fileName: "logs").description == "Check the logs.")
    }
}
