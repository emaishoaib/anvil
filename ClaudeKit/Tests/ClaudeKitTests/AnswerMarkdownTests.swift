import Foundation
import Testing
@testable import ClaudeKit

struct AnswerMarkdownTests {
    @Test func aHeadingKeepsItsLevel() {
        #expect(AnswerMarkdown.blocks(from: "## Setup") == [.heading(level: 2, text: "Setup")])
    }

    @Test func boldItalicAndCodeKeepTheirStyle() {
        let expected = AttributedString("Use ") + styled("bold", .stronglyEmphasized) + AttributedString(", ") + styled("italic", .emphasized) + AttributedString(" and ") + styled("code", .code) + AttributedString(".")
        #expect(AnswerMarkdown.blocks(from: "Use **bold**, *italic* and `code`.") == [.paragraph(expected)])
    }

    @Test func boldInsideItalicIsBothAtOnce() {
        let expected = styled("very ", .emphasized) + styled("much", [.emphasized, .stronglyEmphasized])
        #expect(AnswerMarkdown.blocks(from: "*very **much***") == [.paragraph(expected)])
    }

    @Test func linesOfOneParagraphJoinWithASpace() {
        #expect(AnswerMarkdown.blocks(from: "first line\nsecond line") == [.paragraph("first line second line")])
    }

    @Test func aLinkKeepsWhereItPoints() throws {
        var expected = AttributedString("Swift")
        expected.link = try #require(URL(string: "https://swift.org"))
        #expect(AnswerMarkdown.blocks(from: "[Swift](https://swift.org)") == [.paragraph(expected)])
    }

    @Test func aCodeBlockKeepsItsLanguageAndLinesExactly() {
        let markdown = "```swift\nlet a = 1\n    let b = 2\n```"
        #expect(AnswerMarkdown.blocks(from: markdown) == [.code(language: "swift", code: "let a = 1\n    let b = 2")])
    }

    @Test func aBoxDrawingDiagramInACodeBlockIsKeptAsWritten() {
        let diagram = "┌───┐\n│ A │──▶ B\n└───┘"
        #expect(AnswerMarkdown.blocks(from: "```\n\(diagram)\n```") == [.code(language: nil, code: diagram)])
    }

    @Test func aCodeBlockStillStreamingInRunsToTheEnd() {
        #expect(AnswerMarkdown.blocks(from: "```swift\nlet a = 1") == [.code(language: "swift", code: "let a = 1")])
    }

    @Test func listsKeepWhetherTheyAreNumberedAndWhereTheyStart() {
        #expect(AnswerMarkdown.blocks(from: "- one\n- two") == [.list(start: nil, items: [[.paragraph("one")], [.paragraph("two")]])])
        #expect(AnswerMarkdown.blocks(from: "3. three\n4. four") == [.list(start: 3, items: [[.paragraph("three")], [.paragraph("four")]])])
    }

    @Test func aListInsideAListStaysInsideItsItem() {
        let markdown = "- outer\n  - inner"
        #expect(AnswerMarkdown.blocks(from: markdown) == [.list(start: nil, items: [[.paragraph("outer"), .list(start: nil, items: [[.paragraph("inner")]])]])])
    }

    @Test func aTableKeepsItsHeaderAndRows() {
        let markdown = "| Name | Size |\n| --- | --- |\n| Anvil | 4 MB |\n| Hop | 1 MB |"
        #expect(AnswerMarkdown.blocks(from: markdown) == [.table(header: ["Name", "Size"], rows: [["Anvil", "4 MB"], ["Hop", "1 MB"]])])
    }

    @Test func quotesAndRulesAreKept() {
        #expect(AnswerMarkdown.blocks(from: "> careful\n\n---") == [.quote([.paragraph("careful")]), .rule])
    }

    private func styled(_ string: String, _ intent: InlinePresentationIntent) -> AttributedString {
        var text = AttributedString(string)
        text.inlinePresentationIntent = intent
        return text
    }
}
