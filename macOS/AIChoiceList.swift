import SwiftUI

/// The rows of AI mode's first page, Start Chat and Load Chat, each with what it does. Clicking a row selects it. With nothing matching the search, the page says so.
struct AIChoiceList: View {
    private static let rowHeight: CGFloat = 44
    private static let padding: CGFloat = 8

    let choices: [AIChoice]
    let selected: Int
    let select: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(choices.enumerated()), id: \.element) { index, choice in
                AIChoiceRow(choice: choice, isSelected: index == selected)
                    .frame(height: Self.rowHeight)
                    .onTapGesture { select(index) }
            }
        }
        .frame(height: Self.rowHeight * CGFloat(AIChoice.allCases.count), alignment: .top)
        .overlay { if choices.isEmpty { Text("No Results").foregroundStyle(.secondary) } }
        .padding(Self.padding)
    }
}

private struct AIChoiceRow: View {
    let choice: AIChoice
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            SymbolIcon(symbol: choice.symbol, colour: .orange)
            Text(choice.title)
                .foregroundStyle(Color(nsColor: .textColor))
            Text(choice.subtitle)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}
