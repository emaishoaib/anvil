import Foundation
import Testing
@testable import ClaudeKit

struct ClaudeAuthStatusTests {
    @Test func aSignedOutStatusSaysSo() {
        let output = #"{"loggedIn": false, "authMethod": "none", "apiProvider": "firstParty", "projectsDirectory": "/Users/me/.claude/projects"}"#
        #expect(ClaudeAuthStatus.isSignedIn(Data(output.utf8)) == false)
    }

    @Test func aSignedInStatusSaysSo() {
        let output = #"{"loggedIn": true, "authMethod": "claude.ai", "apiProvider": "firstParty"}"#
        #expect(ClaudeAuthStatus.isSignedIn(Data(output.utf8)) == true)
    }

    @Test func outputThatCannotBeReadGivesNoAnswer() {
        #expect(ClaudeAuthStatus.isSignedIn(Data("command not found".utf8)) == nil)
        #expect(ClaudeAuthStatus.isSignedIn(Data()) == nil)
    }
}
