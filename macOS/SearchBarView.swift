import SwiftUI

struct SearchBarView: View {
    private static let width: CGFloat = 750
    private static let fieldHeight: CGFloat = 56
    private static let tintOpacity = 0.5
    private static let entryHeight: CGFloat = 420
    private static let actionPanelPadding: CGFloat = 8

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
            } else if model.mode == .settings {
                Divider()
                SettingsList(model: model.settings)
                SearchFooter(mode: model.mode, selected: nil, toggleAnvilActions: model.toggleAnvilActions, settingAction: model.settings.selectedActionTitle)
            } else {
                Divider()
                SearchResults(model: model)
                    .overlay(alignment: actionPanelAlignment) {
                        if let panel = model.actionPanel {
                            ActionPanelView(panel: panel, focus: $focus, perform: model.perform)
                                .padding(Self.actionPanelPadding)
                        }
                    }
                SearchFooter(mode: model.mode, selected: model.selectedResult, toggleAnvilActions: model.toggleAnvilActions)
            }
        }
        .frame(width: Self.width)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(nsColor: .windowBackgroundColor).opacity(Self.tintOpacity))
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { SearchBar.shared.fit(height: $0) }
        .onChange(of: model.timesOpened, initial: true) { focus = .query }
        .onChange(of: model.field) { focus = model.field }
        .onChange(of: model.mode.hasSearchField) { if model.mode.hasSearchField { focus = model.field } }
        .onChange(of: focus) { if let focus { model.field = focus } }
    }

    private var actionPanelAlignment: Alignment {
        if case .anvil = model.actionPanel?.subject { .bottomLeading } else { .bottomTrailing }
    }
}
