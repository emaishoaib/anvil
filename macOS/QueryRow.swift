import AppKit
import SwiftUI

struct QueryRow: View {
    private static let fontSize: CGFloat = 17
    private static let caretRoom: CGFloat = 8

    @Bindable var model: SearchModel
    let focus: FocusState<SearchField?>.Binding

    var body: some View {
        HStack(spacing: 12) {
            if model.mode != .launcher {
                BackButton { _ = model.goBack() }
            }
            if model.mode.hasSearchField {
                TextField(model.mode.placeholder, text: $model.query)
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
        }
    }

    private var hasArguments: Bool {
        model.mode == .launcher && !model.arguments.placeholders.isEmpty
    }

    private var queryWidth: CGFloat {
        (model.query as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: Self.fontSize)]).width + Self.caretRoom
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
