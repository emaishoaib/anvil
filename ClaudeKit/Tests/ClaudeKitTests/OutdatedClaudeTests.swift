import Testing
@testable import ClaudeKit

struct OutdatedClaudeTests {
    @Test func anUnknownOptionMeansClaudeCodeIsOutdated() {
        #expect(OutdatedClaude.isOutdated(printing: "error: unknown option '--permission-prompts'"))
    }

    @Test func anUnknownOptionAfterOtherErrorsStillMeansClaudeCodeIsOutdated() {
        #expect(OutdatedClaude.isOutdated(printing: "warning: something else\nerror: unknown option '--permission-prompts'"))
    }

    @Test func otherErrorsDoNotMeanClaudeCodeIsOutdated() {
        #expect(!OutdatedClaude.isOutdated(printing: "Error: No conversation found with session ID: 97b846cf"))
    }

    @Test func noErrorsDoNotMeanClaudeCodeIsOutdated() {
        #expect(!OutdatedClaude.isOutdated(printing: ""))
    }
}
