import LauncherKit
import SwiftUI

struct ResultRow: View {
    let result: SearchResult
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            switch result {
            case .app(let app):
                AppIcon(path: app.url.path)
                Text(app.name)
                Spacer()
                Text("Application").foregroundStyle(.secondary)
            case .command(let command):
                AppIcon(path: command.iconPath)
                Text(command.name)
                Text(command.subtitle).foregroundStyle(.secondary)
                KeywordTag(keyword: command.keyword)
                Spacer()
                Text("Command").foregroundStyle(.secondary)
            case .word(let word):
                Text(word.text).layoutPriority(1)
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
        Image(nsImage: NSWorkspace.shared.icon(forFile: path))
            .resizable()
            .frame(width: Self.size, height: Self.size)
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

extension LauncherCommand {
    var iconPath: String {
        switch self {
        case .defineWord: "/System/Applications/Dictionary.app"
        }
    }
}
