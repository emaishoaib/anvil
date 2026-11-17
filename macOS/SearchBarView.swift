import SwiftUI

struct SearchBarView: View {
    private static let width: CGFloat = 750
    private static let fieldHeight: CGFloat = 56
    private static let fieldPadding: CGFloat = 12
    private static let tintOpacity = 0.5
    private static let entryHeight: CGFloat = 420
    private static let actionPanelPadding: CGFloat = 8
    private static let pinnedOutlineWidth: CGFloat = 2
    private static let swapAnimation = Animation.spring(duration: 0.35, bounce: 0.15)

    @Bindable var model: SearchModel
    @FocusState private var focus: SearchField?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(sections, id: \.self) { section in
                switch section {
                case .query: queryRow
                case .content: content
                case .footer: footer
                }
            }
        }
        .animation(PanelAnimation.isReduced ? nil : Self.swapAnimation, value: model.mode == .askClaude)
        .frame(width: model.isExpanded ? nil : Self.width)
        .frame(maxWidth: model.isExpanded ? .infinity : nil, maxHeight: model.isExpanded ? .infinity : nil, alignment: .top)
        .fixedSize(horizontal: false, vertical: !model.isExpanded)
        .background(Color(nsColor: .windowBackgroundColor).opacity(Self.tintOpacity))
        .overlay {
            if model.isPinned {
                RoundedRectangle(cornerRadius: SearchStyle.barCornerRadius)
                    .strokeBorder(Color.accentColor, lineWidth: Self.pinnedOutlineWidth)
            }
        }
        .onGeometryChange(for: CGSize.self) { $0.size } action: { SearchBar.shared.fit($0) }
        .onChange(of: model.timesOpened, initial: true) { focus = .query }
        .onChange(of: model.field) { focus = model.field }
        .onChange(of: model.mode.hasSearchField) { if model.mode.hasSearchField { focus = model.field } }
        .onChange(of: focus) { if let focus { model.field = focus } }
    }

    /// The order of the bar's three sections. AI mode puts the prompt at the bottom, like a chat, and the footer at the top. Each section keeps its identity when the order changes, so the prompt keeps its focus and the sections slide into place.
    private var sections: [SearchBarSection] {
        model.mode == .askClaude ? [.footer, .content, .query] : [.query, .content, .footer]
    }

    private var queryRow: some View {
        QueryRow(model: model, focus: $focus)
            .padding(.horizontal, 16)
            .padding(.vertical, Self.fieldPadding)
            .frame(minHeight: Self.fieldHeight)
    }

    @ViewBuilder private var content: some View {
        if case .wordEntry = model.mode {
            Divider()
            EntryView(page: model.entryPage)
                .frame(height: Self.entryHeight)
        } else if case .quickLinkForm = model.mode {
            Divider()
            QuickLinkForm(draft: $model.draft)
        } else if case .ruleForm(let group, _, _) = model.mode {
            Divider()
            RuleForm(draft: $model.ruleDraft, group: group)
        } else if case .keySwapForm = model.mode {
            Divider()
            KeySwapForm(draft: $model.keySwapDraft)
        } else if case .uninstallReview = model.mode, let review = model.review {
            Divider()
            UninstallReviewList(review: review, query: model.query)
        } else if model.mode == .savedChats, let list = model.savedChatList {
            Divider()
            SavedChatListView(list: list, query: model.query)
        } else if model.mode == .askClaude {
            ClaudeChat(chat: model.chat, state: model.chatState, isExpanded: model.isExpanded, save: model.saveChat, discard: model.discardChat)
            Divider()
            ChatSetupRow(setup: model.chatSetup, chat: model.chat, ending: model.plannedEnding, isSaved: model.isChatSaved)
        } else if model.mode == .settings {
            Divider()
            SettingsList(model: model.settings, open: { model.open($0) })
                .overlay(alignment: actionPanelAlignment) { actionPanel }
        } else {
            Divider()
            SearchResults(model: model)
                .overlay(alignment: actionPanelAlignment) { actionPanel }
        }
    }

    @ViewBuilder private var footer: some View {
        if case .uninstallReview = model.mode, let review = model.review {
            SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions, message: review.summary, performAction: { _ = model.moveTickedToTrash() })
        } else if model.mode == .askClaude {
            SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions, chatState: model.chatState, isChatSaved: model.isChatSaved, dividerEdge: .bottom)
        } else if model.mode == .settings {
            SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions, settingAction: model.settings.selectedActionTitle, message: model.settings.message)
        } else {
            SearchFooter(mode: model.mode, selected: model.selectedResult, toggleAnvilActions: model.toggleAnvilActions)
        }
    }

    @ViewBuilder private var actionPanel: some View {
        if let panel = model.actionPanel {
            ActionPanelView(panel: panel, focus: $focus, perform: model.perform)
                .padding(Self.actionPanelPadding)
        }
    }

    private var actionPanelAlignment: Alignment {
        if case .anvil = model.actionPanel?.subject { .bottomLeading } else { .bottomTrailing }
    }
}

private enum SearchBarSection {
    case query
    case content
    case footer
}
