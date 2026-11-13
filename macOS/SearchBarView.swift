import SwiftUI

struct SearchBarView: View {
    private static let width: CGFloat = 750
    private static let fieldHeight: CGFloat = 56
    private static let fontSize: CGFloat = 17

    @Bindable var model: SearchModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search for apps and quick links…", text: $model.query)
                .textFieldStyle(.plain)
                .font(.system(size: Self.fontSize))
                .focused($isFocused)
                .padding(.horizontal, 16)
                .frame(height: Self.fieldHeight)
            if !model.results.isEmpty {
                Divider()
                SearchResults(model: model)
            }
        }
        .frame(width: Self.width)
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { SearchBar.shared.fit(height: $0) }
        .onAppear { isFocused = true }
    }
}
