import Foundation

/// One block of Claude's answer once its markdown is read, such as a heading, a paragraph or a code block. Text inside a block keeps its bold, italic, code and links as attributes, so it can be drawn as Claude Code would show it.
public indirect enum AnswerBlock: Equatable, Sendable {
    case heading(level: Int, text: AttributedString)
    case paragraph(AttributedString)
    case code(language: String?, code: String)
    case list(start: Int?, items: [[AnswerBlock]])
    case quote([AnswerBlock])
    case table(header: [AttributedString], rows: [[AttributedString]])
    case rule
}
