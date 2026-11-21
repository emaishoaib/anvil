import LauncherKit
import SwiftUI

struct ResultRow: View {
    let result: SearchResult
    let isSelected: Bool
    var appDetail = "Application"
    var query = ""

    var body: some View {
        HStack(spacing: 10) {
            switch result {
            case .app(let app):
                AppIcon(path: app.url.path)
                Text(app.name).foregroundStyle(Color(nsColor: .textColor))
                Spacer()
                Text(appDetail).foregroundStyle(.secondary)
            case .command(let command):
                CommandIcon(command: command)
                Text(command.name).foregroundStyle(Color(nsColor: .textColor))
                Text(command.subtitle).foregroundStyle(.secondary)
                KeywordTag(keyword: command.keyword)
                Spacer()
                Text("Command").foregroundStyle(.secondary)
            case .quickLink(let link):
                QuickLinkIcon(link: link)
                HighlightedText(text: link.name, highlights: NameMatch.matchedWordStarts(in: link.name, query: query))
                    .foregroundStyle(Color(nsColor: .textColor))
                if let host = link.host {
                    HighlightedText(text: host, highlights: NameMatch.matchedWordStarts(in: host, query: query))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Quick Link").foregroundStyle(.secondary)
            case .word(let word):
                Text(word.text).foregroundStyle(Color(nsColor: .textColor)).layoutPriority(1)
                Text(word.definition).foregroundStyle(.secondary).lineLimit(1)
                Spacer(minLength: 0)
            case .answer:
                EmptyView()
            }
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}

struct AppIcon: View {
    private static let size: CGFloat = 22

    let path: String

    var body: some View {
        Image(nsImage: AppIcons.shared.icon(forFile: path))
            .resizable()
            .frame(width: Self.size, height: Self.size)
    }
}

/// Text with the parts that matched the query drawn in the main text colour and bold, so it shows why a result came up. The rest takes whatever colour the caller gives it.
private struct HighlightedText: View {
    let text: String
    let highlights: [Range<String.Index>]

    var body: some View {
        Text(attributed)
    }

    private var attributed: AttributedString {
        var attributed = AttributedString(text)
        for highlight in highlights {
            guard let range = Range(highlight, in: attributed) else { continue }
            attributed[range].foregroundColor = Color(nsColor: .textColor)
            attributed[range].inlinePresentationIntent = .stronglyEmphasized
        }
        return attributed
    }
}

private struct KeywordTag: View {
    let keyword: String

    var body: some View {
        Text(keyword)
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(.secondary.opacity(0.6)))
    }
}
