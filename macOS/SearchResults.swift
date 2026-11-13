import LauncherKit
import SwiftUI

struct SearchResults: View {
    private static let rowHeight: CGFloat = 40
    private static let headerHeight: CGFloat = 30
    private static let padding: CGFloat = 8
    private static let maximumHeight: CGFloat = 380

    let model: SearchModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !answers.isEmpty {
                        SectionHeader(title: "Calculator")
                        ForEach(answers, id: \.index) { item in
                            AnswerCard(answer: item.answer, isSelected: item.index == model.selected)
                                .id(item.index)
                                .onTapGesture { model.open(.answer(item.answer)) }
                        }
                    }
                    if !apps.isEmpty {
                        SectionHeader(title: "Results")
                        ForEach(apps, id: \.index) { item in
                            AppRow(app: item.app, isSelected: item.index == model.selected)
                                .frame(height: Self.rowHeight)
                                .id(item.index)
                                .onTapGesture { model.open(.app(item.app)) }
                        }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: min(contentHeight, Self.maximumHeight) + Self.padding * 2)
            .onChange(of: model.selected) { proxy.scrollTo(model.selected) }
        }
    }

    private var answers: [(index: Int, answer: Answer)] {
        model.results.enumerated().compactMap { index, result in
            guard case .answer(let answer) = result else { return nil }
            return (index, answer)
        }
    }

    private var apps: [(index: Int, app: InstalledApp)] {
        model.results.enumerated().compactMap { index, result in
            guard case .app(let app) = result else { return nil }
            return (index, app)
        }
    }

    private var contentHeight: CGFloat {
        sectionHeight(count: answers.count, itemHeight: AnswerCard.height) + sectionHeight(count: apps.count, itemHeight: Self.rowHeight)
    }

    private func sectionHeight(count: Int, itemHeight: CGFloat) -> CGFloat {
        count == 0 ? 0 : Self.headerHeight + CGFloat(count) * itemHeight
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.leading, 8)
            .frame(height: 30, alignment: .center)
    }
}

private struct AppRow: View {
    private static let iconSize: CGFloat = 22

    let app: InstalledApp
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                .resizable()
                .frame(width: Self.iconSize, height: Self.iconSize)
            Text(app.name)
            Spacer()
            Text("Application")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}
