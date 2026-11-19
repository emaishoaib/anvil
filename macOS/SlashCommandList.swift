import ClaudeKit
import SwiftUI

/// The skills and commands matching what was typed after a slash, shown over the end of the chat just above the prompt, each with its name and what it does. The selected one stays in view, and clicking one puts it in the prompt.
struct SlashCommandList: View {
    private static let rowHeight: CGFloat = 40
    private static let visibleRows = 6
    private static let padding: CGFloat = 6
    private static let cornerRadius: CGFloat = 10

    let picker: SlashCommandPicker
    let complete: () -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(picker.matches.enumerated()), id: \.element.name) { index, command in
                        SlashCommandRow(command: command, isSelected: index == picker.selected)
                            .frame(height: Self.rowHeight)
                            .id(index)
                            .onTapGesture {
                                picker.select(index)
                                complete()
                            }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: CGFloat(min(picker.matches.count, Self.visibleRows)) * Self.rowHeight + Self.padding * 2)
            .onChange(of: picker.selected) { proxy.scrollTo(picker.selected) }
        }
        .background(.regularMaterial, in: .rect(cornerRadius: Self.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.3)))
    }
}

private struct SlashCommandRow: View {
    let command: SlashCommand
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("/\(command.name)")
                .fontWeight(.medium)
                .foregroundStyle(Color(nsColor: .textColor))
                .lineLimit(1)
            if !command.description.isEmpty {
                Text(command.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}
