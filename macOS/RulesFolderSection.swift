import SwiftUI

struct RulesFolderSection: View {
    private let folder = RulesFolder.shared

    var body: some View {
        Section {
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
            Text("Rules and key swaps are read from rules.json and key-swaps.json in this folder, and changes are saved back there. A folder without them starts with the rules you have now.")
                .foregroundStyle(.secondary)
        }
    }
}
