import SwiftUI

struct SearchBarView: View {
    private static let width: CGFloat = 750
    private static let fieldHeight: CGFloat = 56
    private static let tintOpacity = 0.5
    private static let entryHeight: CGFloat = 420

    @Bindable var model: SearchModel

    var body: some View {
        VStack(spacing: 0) {
            QueryRow(model: model)
                .padding(.horizontal, 16)
                .frame(height: Self.fieldHeight)
            if case .wordEntry = model.mode {
                Divider()
                EntryView(page: model.entryPage)
                    .frame(height: Self.entryHeight)
                SearchFooter(mode: model.mode, selected: nil)
            } else if case .quickLinkForm = model.mode {
                Divider()
                QuickLinkForm(draft: $model.draft)
                SearchFooter(mode: model.mode, selected: nil)
            } else if !model.results.isEmpty {
                Divider()
                SearchResults(model: model)
                SearchFooter(mode: model.mode, selected: model.selectedResult)
            }
        }
        .frame(width: Self.width)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(nsColor: .windowBackgroundColor).opacity(Self.tintOpacity))
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { SearchBar.shared.fit(height: $0) }
    }
}
