import ClaudeKit
import SwiftUI

/// Claude's answer drawn the way Claude Code shows it: headings as headings, code in monospaced boxes, lists with their bullets or numbers, and bold, italic and links kept inside the text. Lists and quotes hold answers of their own, so they draw with this same view.
struct AnswerView: View {
    let blocks: [AnswerBlock]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                BlockView(block: block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct BlockView: View {
    private static let quoteBarWidth: CGFloat = 3

    let block: AnswerBlock

    var body: some View {
        switch block {
        case .heading(let level, let text):
            Text(text)
                .font(Self.font(forHeadingLevel: level))
                .padding(.top, 4)
        case .paragraph(let text):
            Text(text)
        case .code(let language, let code):
            CodeBlockView(language: language, code: code)
        case .list(let start, let items):
            AnswerList(start: start, items: items)
        case .quote(let blocks):
            HStack(alignment: .top, spacing: 10) {
                Rectangle()
                    .fill(.secondary.opacity(0.5))
                    .frame(width: Self.quoteBarWidth)
                AnswerView(blocks: blocks)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        case .table(let header, let rows):
            AnswerTable(header: header, rows: rows)
        case .rule:
            Divider()
        }
    }

    private static func font(forHeadingLevel level: Int) -> Font {
        switch level {
        case 1: .title2.bold()
        case 2: .title3.bold()
        default: .headline
        }
    }
}
