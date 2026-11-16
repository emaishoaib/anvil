import Testing
@testable import ClaudeKit

struct PermissionModeTests {
    @Test func eachModeIsNamedAsClaudeCodesFlagExpects() {
        #expect(PermissionMode.allCases.map(\.rawValue) == ["auto", "manual", "acceptEdits", "plan", "bypassPermissions"])
    }

    @Test func steppingThroughTheModesVisitsEachOnceAndComesBackToTheStart() {
        var visited: [PermissionMode] = []
        var mode = PermissionMode.auto
        for _ in PermissionMode.allCases {
            visited.append(mode)
            mode = mode.next
        }
        #expect(visited == PermissionMode.allCases)
        #expect(mode == .auto)
    }
}
