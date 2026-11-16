import Foundation
import Markdown

/// Reads Claude's answer as markdown and turns it into blocks to draw. An answer still streaming in reads fine too: a code block whose closing fence has not arrived yet runs to the end of the text. Raw HTML is shown as code, because Claude Code shows it as written.
public enum AnswerMarkdown {
    public static func blocks(from text: String) -> [AnswerBlock] {
        blocks(in: Document(parsing: text).children)
    }

    private static func blocks(in markups: some Sequence<any Markup>) -> [AnswerBlock] {
        markups.compactMap(block)
    }

    private static func block(_ markup: any Markup) -> AnswerBlock? {
        switch markup {
        case let heading as Heading: .heading(level: heading.level, text: InlineText.attributed(heading.children))
        case let paragraph as Paragraph: .paragraph(InlineText.attributed(paragraph.children))
        case let code as CodeBlock: .code(language: code.language, code: withoutTrailingNewline(code.code))
        case let html as HTMLBlock: .code(language: "html", code: withoutTrailingNewline(html.rawHTML))
        case let list as UnorderedList: .list(start: nil, items: list.listItems.map { blocks(in: $0.children) })
        case let list as OrderedList: .list(start: Int(list.startIndex), items: list.listItems.map { blocks(in: $0.children) })
        case let quote as BlockQuote: .quote(blocks(in: quote.children))
        case let table as Table: .table(header: cells(of: table.head.cells), rows: table.body.rows.map { cells(of: $0.cells) })
        case is ThematicBreak: .rule
        default: nil
        }
    }

    private static func cells(of cells: some Sequence<Table.Cell>) -> [AttributedString] {
        cells.map { InlineText.attributed($0.children) }
    }

    private static func withoutTrailingNewline(_ text: String) -> String {
        text.hasSuffix("\n") ? String(text.dropLast()) : text
    }
}
