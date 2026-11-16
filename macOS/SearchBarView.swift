import SwiftUI

struct SearchBarView: View {
    private static let width: CGFloat = 750
    private static let fieldHeight: CGFloat = 56
    private static let tintOpacity = 0.5
    private static let entryHeight: CGFloat = 420
    private static let actionPanelPadding: CGFloat = 8
    private static let pinnedOutlineWidth: CGFloat = 2

    @Bindable var model: SearchModel
    @FocusState private var focus: SearchField?

    var body: some View {
        VStack(spacing: 0) {
            QueryRow(model: model, focus: $focus)
                .padding(.horizontal, 16)
                .frame(height: Self.fieldHeight)
            if case .wordEntry = model.mode {
                Divider()
                EntryView(page: model.entryPage)
                    .frame(height: Self.entryHeight)
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions)
            } else if case .quickLinkForm = model.mode {
                Divider()
                QuickLinkForm(draft: $model.draft)
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions)
            } else if case .ruleForm(let group, _, _) = model.mode {
                Divider()
                RuleForm(draft: $model.ruleDraft, group: group)
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions)
            } else if case .keySwapForm = model.mode {
                Divider()
                KeySwapForm(draft: $model.keySwapDraft)
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions)
            } else if case .uninstallReview = model.mode, let review = model.review {
                Divider()
                UninstallReviewList(review: review, query: model.query)
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions, message: review.summary, performAction: { _ = model.moveTickedToTrash() })
            } else if model.mode == .askClaude {
                Divider()
                ChatSetupRow(setup: model.chatSetup, isLocked: model.chat != nil)
                ClaudeChat(chat: model.chat)
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions, isChatStarted: model.chat != nil)
            } else if model.mode == .settings {
                Divider()
                SettingsList(model: model.settings, open: { model.open($0) })
                    .overlay(alignment: actionPanelAlignment) { actionPanel }
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions, settingAction: model.settings.selectedActionTitle, message: model.settings.message)
            } else {
                Divider()
                SearchResults(model: model)
                    .overlay(alignment: actionPanelAlignment) { actionPanel }
                SearchFooter(mode: model.mode, selected: model.selectedResult, toggleAnvilActions: model.toggleAnvilActions)
            }
        }
        .frame(width: Self.width)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(nsColor: .windowBackgroundColor).opacity(Self.tintOpacity))
        .overlay {
            if model.isPinned {
                RoundedRectangle(cornerRadius: SearchStyle.barCornerRadius)
                    .strokeBorder(Color.accentColor, lineWidth: Self.pinnedOutlineWidth)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { SearchBar.shared.fit(height: $0) }
        .onChange(of: model.timesOpened, initial: true) { focus = .query }
        .onChange(of: model.field) { focus = model.field }
        .onChange(of: model.mode.hasSearchField) { if model.mode.hasSearchField { focus = model.field } }
        .onChange(of: focus) { if let focus { model.field = focus } }
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
