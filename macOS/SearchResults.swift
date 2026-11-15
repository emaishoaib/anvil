import LauncherKit
import SwiftUI

struct SearchResults: View {
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380

    let model: SearchModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(items, id: \.index) { item in
                        ResultItem(result: item.result, header: item.header, isSelected: item.index == model.selected) {
                            model.open(item.result)
                        }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.listHeight + Self.padding * 2)
            .onChange(of: model.selected) { proxy.scrollTo(model.selected) }
        }
    }

    private var items: [(index: Int, result: SearchResult, header: String?)] {
        let firstAnswer = model.results.firstIndex { $0.isAnswer }
        let firstOther = model.results.firstIndex { !$0.isAnswer }
        return model.results.enumerated().map { index, result in
            let header: String? = if index == firstAnswer { "Calculator" } else if index == firstOther { model.resultsTitle } else { nil }
            return (index, result, header)
        }
    }
}

private struct ResultItem: View {
    private static let rowHeight: CGFloat = 40

    let result: SearchResult
    let header: String?
    let isSelected: Bool
    let open: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header { SectionHeader(title: header) }
            content.onTapGesture(perform: open)
        }
    }

    @ViewBuilder private var content: some View {
        switch result {
        case .answer(let answer):
            AnswerCard(answer: answer, isSelected: isSelected)
        default:
            ResultRow(result: result, isSelected: isSelected)
                .frame(height: Self.rowHeight)
        }
    }
}

private extension SearchResult {
    var isAnswer: Bool {
        if case .answer = self { true } else { false }
    }
}
