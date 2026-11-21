import ClaudeKit
import SwiftUI

/// The rows of AI mode's chat list, pinned sessions first and then the newest: each Claude desktop session's title with a pin when it is pinned, the folder it works in, and how long ago it was last active. Clicking a row selects it. With no sessions, or nothing matching the search, the page says so.
struct DesktopSessionListView: View {
    private static let rowHeight: CGFloat = 44
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380

    let list: DesktopSessionList
    let query: String

    var body: some View {
        let sessions = list.sessions(matching: query)
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(sessions.enumerated()), id: \.element.desktopID) { index, session in
                        DesktopSessionRow(session: session, isSelected: index == list.selected)
                            .frame(height: Self.rowHeight)
                            .id(index)
                            .onTapGesture { list.select(index) }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.listHeight + Self.padding * 2)
            .overlay { if sessions.isEmpty { emptyMessage } }
            .onChange(of: list.selected) { proxy.scrollTo(list.selected) }
        }
    }

    private var emptyMessage: some View {
        Text(list.sessions.isEmpty ? "No Claude Desktop Sessions" : "No Results")
            .foregroundStyle(.secondary)
    }
}

private struct DesktopSessionRow: View {
    let session: DesktopSession
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .foregroundStyle(.secondary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if session.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(session.title)
                        .foregroundStyle(Color(nsColor: .textColor))
                        .lineLimit(1)
                }
                Text((session.folder.path as NSString).abbreviatingWithTildeInPath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Text(session.lastActivity, format: .relative(presentation: .named))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}
