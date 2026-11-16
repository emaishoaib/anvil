import Testing
@testable import ClaudeKit

struct ToolCallSummaryTests {
    @Test func filesAreNamedWithoutTheirFolders() {
        #expect(summary("Read", ["file_path": "/Users/me/anvil/macOS/SearchModel.swift"]) == "Reading SearchModel.swift")
        #expect(summary("Edit", ["file_path": "/Users/me/notes.md"]) == "Editing notes.md")
        #expect(summary("Write", ["file_path": "/Users/me/new.txt"]) == "Writing new.txt")
    }

    @Test func aCommandIsDescribedByClaudesDescriptionWhenItGivesOne() {
        #expect(summary("Bash", ["command": "git log --oneline", "description": "Show recent commits"]) == "Show recent commits")
        #expect(summary("Bash", ["command": "git log --oneline"]) == "Running git log --oneline")
    }

    @Test func searchesNameWhatTheyLookFor() {
        #expect(summary("Glob", ["pattern": "**/*.swift"]) == "Finding files matching **/*.swift")
        #expect(summary("Grep", ["pattern": "SearchMode"]) == "Searching for SearchMode")
        #expect(summary("WebSearch", ["query": "swift markdown"]) == "Searching the web for swift markdown")
    }

    @Test func aWebPageIsNamedByItsSite() {
        #expect(summary("WebFetch", ["url": "https://developer.apple.com/documentation/swiftui"]) == "Reading developer.apple.com")
    }

    @Test func anAgentIsDescribedByItsTask() {
        #expect(summary("Agent", ["description": "Find the search bar code"]) == "Asking an agent to find the search bar code")
    }

    @Test func missingInputsStillGiveASummary() {
        #expect(summary("Read", [:]) == "Reading a file")
        #expect(summary("Bash", [:]) == "Running a command")
    }

    @Test func anUnknownToolIsNamedAsItIs() {
        #expect(summary("mcp__github__create_issue", [:]) == "Using mcp__github__create_issue")
    }

    private func summary(_ name: String, _ input: [String: String]) -> String {
        ToolCall(id: "toolu_1", name: name, input: input).summary
    }
}
