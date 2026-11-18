import Carbon.HIToolbox
import LauncherKit
import SwiftUI

struct SearchFooter: View {
    static let height: CGFloat = 40

    let mode: SearchMode
    let selected: SearchResult?
    let toggleAnvilActions: () -> Void
    var settingAction: String? = nil
    var message: String? = nil
    var performAction: (() -> Void)? = nil
    var chatState = ChatState.notStarted
    var cardChoice: CardChoice? = nil
    var isChatSaved = false
    var dividerEdge = VerticalEdge.top

    var body: some View {
        VStack(spacing: 0) {
            if dividerEdge == .top { Divider() }
            HStack(spacing: 8) {
                switch mode {
                case .launcher:
                    AnvilMenuButton(action: toggleAnvilActions)
                    StatusRow()
                case .defineWord:
                    CommandIcon(command: .defineWord)
                    Text(LauncherCommand.defineWord.name)
                        .foregroundStyle(.secondary)
                case .uninstallApp:
                    CommandIcon(command: .uninstallApp)
                    if LeftoverIndexStore.shared.isSearching {
                        SearchingTheMac()
                    } else {
                        Text(LauncherCommand.uninstallApp.name)
                            .foregroundStyle(.secondary)
                    }
                case .uninstallReview:
                    CommandIcon(command: .uninstallApp)
                    Text(message ?? LauncherCommand.uninstallApp.name)
                        .foregroundStyle(.secondary)
                case .aiChoice:
                    CommandIcon(command: .enterAIMode)
                    Text("AI Mode")
                        .foregroundStyle(.secondary)
                case .savedChats:
                    SymbolIcon(symbol: AIChoice.loadChat.symbol, colour: .orange)
                    Text(AIChoice.loadChat.title)
                        .foregroundStyle(.secondary)
                case .askClaude:
                    SymbolIcon(symbol: AIChoice.startChat.symbol, colour: .orange)
                    Text(AIChoice.startChat.title)
                        .foregroundStyle(.secondary)
                case .wordEntry(let word, _):
                    CommandIcon(command: .defineWord)
                    Text(word.text)
                        .foregroundStyle(.secondary)
                case .quickLinkForm(let kind, _):
                    CommandIcon(command: .createQuickLink)
                    Text(kind.title)
                        .foregroundStyle(.secondary)
                case .ruleForm(let group, let isNew, _):
                    CommandIcon(command: .settings)
                    Text("\(isNew ? "Add" : "Edit") \(group.itemName)")
                        .foregroundStyle(.secondary)
                case .keySwapForm:
                    CommandIcon(command: .settings)
                    Text("Add Key Swap")
                        .foregroundStyle(.secondary)
                case .aliasForm:
                    CommandIcon(command: .settings)
                    Text("Add Alias")
                        .foregroundStyle(.secondary)
                case .shellTextForm(let text, _):
                    CommandIcon(command: .settings)
                    Text("Edit \(text.title)")
                        .foregroundStyle(.secondary)
                case .settings:
                    CommandIcon(command: .settings)
                    if let message {
                        Text(message)
                            .lineLimit(1)
                    } else {
                        Text(LauncherCommand.settings.name)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if case .uninstallReview = mode {
                    Text("Show in Finder")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_ANSI_R, modifiers: .command))
                    FooterDivider()
                }
                if mode == .savedChats {
                    Text("Move to Trash")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Delete, modifiers: .command))
                }
                if mode == .askClaude, chatState == .answering {
                    Text("Stop")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Escape, modifiers: []))
                    if !isChatSaved { FooterDivider() }
                }
                if mode == .askClaude, !isChatSaved, chatState == .started || chatState == .answering {
                    Text("Save")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_ANSI_S, modifiers: .command))
                    if chatState == .started { FooterDivider() }
                }
                if mode == .askClaude, isChatSaved, chatState == .started {
                    Text("Delete")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_ANSI_D, modifiers: .command))
                    FooterDivider()
                }
                if mode == .askClaude, chatState == .askingToDelete {
                    Text("Keep Chatting")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Escape, modifiers: []))
                    FooterDivider()
                }
                if mode == .askClaude, chatState == .askingToLeave {
                    Text("Keep Chatting")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Escape, modifiers: []))
                    FooterDivider()
                    Text("Save and Leave")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_ANSI_S, modifiers: .command))
                    FooterDivider()
                }
                if mode == .askClaude, chatState == .signingIn {
                    Text("Cancel Sign In")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Escape, modifiers: []))
                }
                if mode == .askClaude, chatState == .updating {
                    Text("Stop Update")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Escape, modifiers: []))
                }
                if mode == .askClaude, chatState == .awaitingApproval {
                    Text("Deny")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Escape, modifiers: []))
                    FooterDivider()
                }
                if mode == .askClaude, chatState == .notStarted || chatState == .signedOut {
                    Text("Folder")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_ANSI_O, modifiers: .command))
                    FooterDivider()
                    Text("Mode")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_Tab, modifiers: .shift))
                }
                if let action {
                    let label = ActionLabel(title: action, combo: KeyCombo(keyCode: kVK_Return, modifiers: actionUsesCommand ? .command : []))
                    if let performAction {
                        Button(action: performAction) { label }
                            .buttonStyle(.plain)
                    } else {
                        label
                    }
                }
                if hasActions {
                    FooterDivider()
                    Text("Actions")
                        .foregroundStyle(.secondary)
                    KeyCaps(combo: KeyCombo(keyCode: kVK_ANSI_K, modifiers: .command))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: Self.height - 1)
            .background(.primary.opacity(0.02))
            if dividerEdge == .bottom { Divider() }
        }
    }

    private var actionUsesCommand: Bool {
        if case .uninstallReview = mode { return true }
        return !mode.hasSearchField
    }

    private var hasActions: Bool {
        guard mode == .launcher, case .quickLink = selected else { return false }
        return true
    }

    private var action: String? {
        if mode == .settings { return settingAction }
        if mode == .savedChats { return "Continue Chat" }
        if mode == .aiChoice { return "Open" }
        if mode == .askClaude {
            return switch chatState {
            case .signedOut: "Sign In"
            case .signingIn, .answering, .updating: nil
            case .outdated: "Update Claude Code"
            case .awaitingApproval, .askingToLeave, .askingToDelete: cardChoice?.title
            case .notStarted, .started: "Send"
            }
        }
        if mode == .uninstallApp { return selected == nil || LeftoverIndexStore.shared.isSearching ? nil : "Review Files" }
        if case .uninstallReview = mode { return "Move to Trash" }
        if case .wordEntry = mode { return "Open in Dictionary" }
        if case .quickLinkForm(let kind, _) = mode { return kind.saveTitle }
        if case .keySwapForm = mode { return "Add Key Swap" }
        if case .aliasForm = mode { return "Add Alias" }
        if case .shellTextForm(let text, _) = mode { return "Save \(text.title)" }
        if case .ruleForm(let group, let isNew, _) = mode { return "\(isNew ? "Create" : "Update") \(group.itemName)" }
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

private struct FooterDivider: View {
    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.15))
            .frame(width: 1, height: 16)
    }
}

private struct ActionLabel: View {
    let title: String
    let combo: KeyCombo

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .fontWeight(.medium)
            KeyCaps(combo: combo)
        }
        .contentShape(.rect)
    }
}

private struct SearchingTheMac: View {
    var body: some View {
        ProgressView()
            .controlSize(.small)
        Text("Searching the Mac for leftovers…")
            .foregroundStyle(.secondary)
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
