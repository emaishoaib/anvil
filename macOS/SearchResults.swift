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
                    ForEach(rows) { row in
                        switch row {
                        case .result(let item): resultItem(item)
                        case .currencies(let table): CurrencyTableView(table: table)
                        }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.listHeight + Self.padding * 2)
            .overlay { if model.results.isEmpty, model.currencyTable == nil, !model.isQueryEmpty { NoResults() } }
            .onChange(of: model.selected) { proxy.scrollTo(model.selected) }
        }
    }

    private func resultItem(_ item: ResultsItem) -> ResultItem {
        ResultItem(result: item.result, header: item.header, isSelected: item.index == model.selected, appDetail: appDetail(for: item.result), query: model.query) {
            model.open(item.result)
        }
    }

    private func appDetail(for result: SearchResult) -> String {
        guard model.mode == .uninstallApp, case .app(let app) = result else { return "Application" }
        guard !LeftoverIndexStore.shared.isSearching else { return "Searching…" }
        return AppSizes.shared.bytes(of: app.url)?.formatted(.byteCount(style: .file)) ?? "Measuring…"
    }

    private var rows: [ResultsRow] {
        let rows = items.map(ResultsRow.result)
        guard let table = model.currencyTable else { return rows }
        let tablePosition = items.firstIndex { !$0.result.isAnswer } ?? items.count
        return Array(rows[..<tablePosition]) + [.currencies(table)] + rows[tablePosition...]
    }

    private var items: [ResultsItem] {
        let firstAnswer = model.results.firstIndex { $0.isAnswer }
        let firstOther = model.results.firstIndex { !$0.isAnswer }
        return model.results.enumerated().map { index, result in
            let header: String? = if index == firstAnswer { "Calculator" } else if index == firstOther { model.resultsTitle } else { nil }
            return (index, result, header)
        }
    }
}

private typealias ResultsItem = (index: Int, result: SearchResult, header: String?)

/// One row of the list: a result tracked by its place in the results, so the selection can scroll to it, or the currency table, which has an ID no result can have.
private enum ResultsRow: Identifiable {
    private static let currenciesID = -1

    case result(ResultsItem)
    case currencies(CurrencyTable)

    var id: Int {
        switch self {
        case .result(let item): item.index
        case .currencies: Self.currenciesID
        }
    }
}

private struct ResultItem: View {
    private static let rowHeight: CGFloat = 40

    let result: SearchResult
    let header: String?
    let isSelected: Bool
    let appDetail: String
    let query: String
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
            ResultRow(result: result, isSelected: isSelected, appDetail: appDetail, query: query)
                .frame(height: Self.rowHeight)
        }
    }
}

private extension SearchResult {
    var isAnswer: Bool {
        if case .answer = self { true } else { false }
    }
}
