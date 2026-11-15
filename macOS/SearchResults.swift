import LauncherKit
import SwiftUI

struct SearchResults: View {
    private static let rowHeight: CGFloat = 40
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380

    let model: SearchModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if !answers.isEmpty {
                        SectionHeader(title: "Calculator")
                        ForEach(answers, id: \.index) { item in
                            AnswerCard(answer: item.answer, isSelected: item.index == model.selected)
                                .onTapGesture { model.open(.answer(item.answer)) }
                        }
                    }
                    if !others.isEmpty {
                        SectionHeader(title: model.resultsTitle)
                        ForEach(others, id: \.index) { item in
                            ResultRow(result: item.result, isSelected: item.index == model.selected)
                                .frame(height: Self.rowHeight)
                                .onTapGesture { model.open(item.result) }
                        }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.listHeight + Self.padding * 2)
            .onChange(of: model.selected) { proxy.scrollTo(model.selected) }
        }
    }

    private var answers: [(index: Int, answer: Answer)] {
        model.results.enumerated().compactMap { index, result in
            guard case .answer(let answer) = result else { return nil }
            return (index, answer)
        }
    }

    private var others: [(index: Int, result: SearchResult)] {
        model.results.enumerated().compactMap { index, result in
            if case .answer = result { return nil }
            return (index, result)
        }
    }
}
