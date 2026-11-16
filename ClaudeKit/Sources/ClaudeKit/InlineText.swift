import Foundation
import Markdown

/// Turns the text inside a markdown block into one attributed string. Bold, italic, inline code and struck-through text become presentation intents, which stack when nested, and links keep where they point. An image shows as its description.
enum InlineText {
    static func attributed(_ inlines: some Sequence<any Markup>, intent: InlinePresentationIntent = [], link: URL? = nil) -> AttributedString {
        inlines.reduce(into: AttributedString()) { text, inline in
            text += attributed(inline, intent: intent, link: link)
        }
    }

    private static func attributed(_ inline: any Markup, intent: InlinePresentationIntent, link: URL?) -> AttributedString {
        switch inline {
        case let text as Markdown.Text: styled(text.string, intent: intent, link: link)
        case let code as InlineCode: styled(code.code, intent: intent.union(.code), link: link)
        case let html as InlineHTML: styled(html.rawHTML, intent: intent.union(.code), link: link)
        case is SoftBreak: styled(" ", intent: intent, link: link)
        case is LineBreak: styled("\n", intent: intent, link: link)
        case let strong as Strong: attributed(strong.children, intent: intent.union(.stronglyEmphasized), link: link)
        case let emphasis as Emphasis: attributed(emphasis.children, intent: intent.union(.emphasized), link: link)
        case let struck as Strikethrough: attributed(struck.children, intent: intent.union(.strikethrough), link: link)
        case let linked as Markdown.Link: attributed(linked.children, intent: intent, link: linked.destination.flatMap(URL.init(string:)))
        default: attributed(inline.children, intent: intent, link: link)
        }
    }

    private static func styled(_ string: String, intent: InlinePresentationIntent, link: URL?) -> AttributedString {
        var text = AttributedString(string)
        if !intent.isEmpty { text.inlinePresentationIntent = intent }
        text.link = link
        return text
    }
}
