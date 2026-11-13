import SwiftUI

struct SearchBarView: View {
    private static let width: CGFloat = 750
    private static let fieldHeight: CGFloat = 56
    private static let fontSize: CGFloat = 17
    private static let tintOpacity = 0.5
    private static let entryHeight: CGFloat = 420

    @Bindable var model: SearchModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if model.mode != .launcher {
                    BackButton { _ = model.goBack() }
                }
                TextField(model.mode.placeholder, text: $model.query)
                    .textFieldStyle(.plain)
                    .font(.system(size: Self.fontSize))
                    .focused($isFocused)
            }
            .padding(.horizontal, 16)
            .frame(height: Self.fieldHeight)
            if case .wordEntry = model.mode {
                Divider()
                EntryView(page: model.entryPage)
                    .frame(height: Self.entryHeight)
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
        .onAppear { isFocused = true }
    }
}

private struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 28, height: 28)
                .background(.primary.opacity(0.08), in: .rect(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}
