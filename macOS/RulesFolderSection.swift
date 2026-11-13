import SwiftUI

struct RulesFolderSection: View {
    private let folder = RulesFolder.shared
    private let mouseSettings = MouseSettingsLibrary.shared

    var body: some View {
        Section {
            if let problem = mouseSettings.loadProblem {
                Label(problem, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
            LabeledContent("Rules Folder") {
                Text(folder.displayPath)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            HStack {
                Button("Choose Folder…") { folder.choose() }
                if folder.url != nil {
                    Button("Use Anvil's Settings") { folder.useSettings() }
                    Spacer()
                    Button("Reload", systemImage: "arrow.clockwise") { folder.reload() }
                }
            }
        } footer: {
            Text("Rules, key swaps and the Mouse page's settings are read from rules.json, key-swaps.json and mouse.json in this folder, and changes are saved back there. A folder without them starts with the settings you have now.")
                .foregroundStyle(.secondary)
        }
    }
}
