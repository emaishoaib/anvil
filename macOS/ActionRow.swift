import Carbon.HIToolbox
import LauncherKit
import SwiftUI

struct ActionRow: View {
    static let height: CGFloat = 36

    let item: ActionPanel.Item
    let link: QuickLink
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            icon
                .frame(width: 22)
            Text(title)
                .foregroundStyle(isDestructive ? Color.red : Color.primary)
            Spacer()
            if let shortcut {
                KeyCaps(combo: shortcut)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: Self.height)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }

    @ViewBuilder private var icon: some View {
        switch item {
        case .action(.open): QuickLinkIcon(link: link)
        case .action(let action): Symbol(name: action.symbol, isDestructive: action.isDestructive)
        case .app(let app): AppIcon(path: app.path)
        case .confirmDelete: Symbol(name: "trash", isDestructive: true)
        case .cancel: Symbol(name: "xmark", isDestructive: false)
        }
    }

    private var title: String {
        switch item {
        case .action(let action): action.name(openingIn: link.app?.appName)
        case .app(let app): app.appName
        case .confirmDelete: QuickLinkAction.delete.name(openingIn: nil)
        case .cancel: "Cancel"
        }
    }

    private var isDestructive: Bool {
        switch item {
        case .action(let action): action.isDestructive
        case .confirmDelete: true
        case .app, .cancel: false
        }
    }

    private var shortcut: KeyCombo? {
        switch item {
        case .action(let action): action.shortcut
        case .confirmDelete: KeyCombo(keyCode: kVK_Return, modifiers: [])
        case .cancel: KeyCombo(keyCode: kVK_Escape, modifiers: [])
        case .app: nil
        }
    }
}

private struct Symbol: View {
    let name: String
    let isDestructive: Bool

    var body: some View {
        Image(systemName: name)
            .font(.system(size: 14))
            .foregroundStyle(isDestructive ? Color.red : Color.primary)
    }
}

private extension QuickLinkAction {
    var symbol: String {
        switch self {
        case .open: "arrow.up.right.square"
        case .openWith: "square.and.arrow.up"
        case .edit: "pencil"
        case .duplicate: "plus.square.on.square"
        case .resetRanking: "arrow.counterclockwise"
        case .copyName, .copyLink: "doc.on.clipboard"
        case .delete: "trash"
        }
    }
}
