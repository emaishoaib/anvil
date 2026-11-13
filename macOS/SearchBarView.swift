import SwiftUI

struct SearchBarView: View {
    private static let width: CGFloat = 750
    private static let height: CGFloat = 56
    private static let fontSize: CGFloat = 17

    @State private var query = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("Search for apps and quick links…", text: $query)
            .textFieldStyle(.plain)
            .font(.system(size: Self.fontSize))
            .focused($isFocused)
            .padding(.horizontal, 16)
            .frame(width: Self.width, height: Self.height)
            .onAppear { isFocused = true }
            .onExitCommand { SearchBar.shared.hide() }
    }
}
