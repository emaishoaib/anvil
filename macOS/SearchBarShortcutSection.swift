import SwiftUI

@MainActor @Observable final class SearchBarShortcutModel {
    private(set) var combo = LauncherKeys.shared.openSearchBarCombo

    var clashes: [ShortcutClash] {
        Tool.launcher.clashes(with: Shortcut(combo: combo, action: "Open Search Bar"))
    }

    func set(_ newCombo: KeyCombo) {
        LauncherKeys.shared.setOpenSearchBarCombo(newCombo)
        combo = newCombo
    }
}

struct SearchBarShortcutSection: View {
    @State private var model = SearchBarShortcutModel()

    var body: some View {
        Section("Search Bar") {
            LabeledContent {
                ShortcutRecorder(combo: model.combo, canClear: false) { combo in
                    if let combo { model.set(combo) }
                }
            } label: {
                Text("Open Search Bar")
                if !model.clashes.isEmpty {
                    Label("Also used by \(model.clashes.map(\.name).formatted(.list(type: .and)))", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
