import SwiftUI

/// The rows of the saved chats page, newest first: each chat's title, the folder it ran in, and how long ago it was saved. Clicking a row selects it. With nothing saved, or nothing matching the search, the page says so.
struct SavedChatListView: View {
    private static let rowHeight: CGFloat = 44
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380

    let list: SavedChatList
    let query: String

    var body: some View {
        let chats = list.chats(matching: query)
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(chats.enumerated()), id: \.element.id) { index, chat in
                        SavedChatRow(chat: chat, isSelected: index == list.selected)
                            .frame(height: Self.rowHeight)
                            .id(index)
                            .onTapGesture { list.select(index) }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.listHeight + Self.padding * 2)
            .overlay { if chats.isEmpty { emptyMessage } }
            .onChange(of: list.selected) { proxy.scrollTo(list.selected) }
        }
    }

    private var emptyMessage: some View {
        Text(list.chats.isEmpty ? "No Saved Chats" : "No Results")
            .foregroundStyle(.secondary)
    }
}

private struct SavedChatRow: View {
    let chat: SavedChat
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .foregroundStyle(.secondary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(chat.title)
                    .foregroundStyle(Color(nsColor: .textColor))
                    .lineLimit(1)
                Text((chat.folder.path as NSString).abbreviatingWithTildeInPath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Text(chat.savedAt, format: .relative(presentation: .named))
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
