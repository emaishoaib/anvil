import AppKit
import SwiftUI

struct QueryRow: View {
    private static let fontSize: CGFloat = 17
    private static let caretRoom: CGFloat = 8
    private static let promptLineLimit = 6

    @Bindable var model: SearchModel
    let focus: FocusState<SearchField?>.Binding

    var body: some View {
        HStack(spacing: 12) {
            if model.mode != .launcher {
                BackButton { _ = model.goBack() }
            }
            if model.mode.hasSearchField {
                TextField(model.mode.placeholder, text: query, axis: model.mode == .askClaude ? .vertical : .horizontal)
                    .lineLimit(1...Self.promptLineLimit)
                    .textFieldStyle(.plain)
                    .font(.system(size: Self.fontSize))
                    .focused(focus, equals: .query)
                    .frame(width: hasArguments ? queryWidth : nil)
            } else {
                Spacer()
            }
            if hasArguments {
                ForEach(Array(model.arguments.placeholders.enumerated()), id: \.offset) { index, hint in
                    ArgumentField(hint: hint, text: argument(at: index))
                        .focused(focus, equals: .argument(index))
                }
                Spacer(minLength: 0)
            }
            if model.mode == .askClaude {
                ExpandButton(isExpanded: model.isExpanded, action: SearchBar.shared.toggleExpanded)
            }
            PinButton(isPinned: model.isPinned, action: model.togglePin)
        }
    }

    private var hasArguments: Bool {
        model.mode == .launcher && !model.arguments.placeholders.isEmpty
    }

    private var queryWidth: CGFloat {
        (model.query as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: Self.fontSize)]).width + Self.caretRoom
    }

    /// Writes to the model only when the text really changed, because the field
    /// writes its unchanged text back whenever it loses focus, and that would
    /// re-run the search and reset the selected result.
    private var query: Binding<String> {
        Binding(
            get: { model.query },
            set: { if $0 != model.query { model.query = $0 } }
        )
    }

    private func argument(at index: Int) -> Binding<String> {
        Binding(
            get: { model.arguments.value(at: index) },
            set: { model.arguments.set($0, at: index) }
        )
    }
}

private struct ArgumentField: View {
    let hint: String
    @Binding var text: String

    var body: some View {
        TextField(hint, text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: 15))
            .padding(.horizontal, 10)
            .frame(width: 150, height: 32)
            .background(.primary.opacity(0.05), in: .rect(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.4)))
    }
}

private struct PinButton: View {
    let isPinned: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isPinned ? Color.accentColor : .secondary)
                .frame(width: 28, height: 28)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help(isPinned ? "Unpin" : "Pin")
    }
}

private struct ExpandButton: View {
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help(isExpanded ? "Shrink (Command E)" : "Expand (Command E)")
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
