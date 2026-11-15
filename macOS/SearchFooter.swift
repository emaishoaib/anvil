import Carbon.HIToolbox
import LauncherKit
import SwiftUI

struct SearchFooter: View {
    static let height: CGFloat = 40

    let mode: SearchMode
    let selected: SearchResult?
    let toggleAnvilActions: () -> Void
    var settingAction: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 8) {
                switch mode {
                case .launcher:
                    AnvilMenuButton(action: toggleAnvilActions)
                case .defineWord:
                    CommandIcon(command: .defineWord)
                    Text(LauncherCommand.defineWord.name)
                        .foregroundStyle(.secondary)
                case .wordEntry(let word, _):
                    CommandIcon(command: .defineWord)
                    Text(word.text)
                        .foregroundStyle(.secondary)
                case .quickLinkForm(let kind, _):
                    CommandIcon(command: .createQuickLink)
                    Text(kind.title)
                        .foregroundStyle(.secondary)
                case .settings:
                    CommandIcon(command: .settings)
                    Text(LauncherCommand.settings.name)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let action {
                    Text(action)
                        .fontWeight(.medium)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Return, modifiers: mode.hasSearchField ? [] : .command))
                }
                if hasActions {
                    Rectangle()
                        .fill(.primary.opacity(0.15))
                        .frame(width: 1, height: 16)
                    Text("Actions")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_ANSI_K, modifiers: .command))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: Self.height - 1)
            .background(.primary.opacity(0.02))
        }
    }

    private var hasActions: Bool {
        guard mode == .launcher, case .quickLink = selected else { return false }
        return true
    }

    private var action: String? {
        if mode == .settings { return settingAction }
        if case .wordEntry = mode { return "Open in Dictionary" }
        if case .quickLinkForm(let kind, _) = mode { return kind.saveTitle }
        return switch selected {
        case .answer: "Copy Answer"
        case .app: "Open Application"
        case .command: "Open Command"
        case .quickLink(let link): link.app.map { "Open in \($0.appName)" } ?? "Open Quick Link"
        case .word: "Show Details"
        case nil: nil
        }
    }
}

private struct AnvilMenuButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(.menuBarIcon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.secondary)
                .padding(4)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help("Anvil")
    }
}
