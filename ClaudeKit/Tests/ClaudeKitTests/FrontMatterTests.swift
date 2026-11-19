import Testing
@testable import ClaudeKit

struct FrontMatterTests {
    @Test func plainAndQuotedValuesAreRead() {
        let contents = """
        ---
        name: capture
        description: "Logs what was learned, 'quoted' inside."
        ---
        Body
        """
        #expect(FrontMatter.fields(in: contents) == ["name": "capture", "description": "Logs what was learned, 'quoted' inside."])
    }

    @Test func aValueOverSeveralIndentedLinesIsJoinedWithSpaces() {
        let contents = """
        ---
        name: engineer
        description: >
          Activates collaborative engineering mode.
          One step at a time.
        user-invocable: true
        ---
        """
        let fields = FrontMatter.fields(in: contents)
        #expect(fields["description"] == "Activates collaborative engineering mode. One step at a time.")
        #expect(fields["user-invocable"] == "true")
    }

    @Test func aFileWithoutFieldsHasNoneAndIsAllBody() {
        let contents = "# Deploy\nRuns the deploy."
        #expect(FrontMatter.fields(in: contents).isEmpty)
        #expect(FrontMatter.body(of: contents) == contents)
    }

    @Test func theBodyIsWhatFollowsTheFields() {
        #expect(FrontMatter.body(of: "---\nname: x\n---\nFirst line\nSecond") == "First line\nSecond")
    }
}
