import SwiftUI

struct SettingsFolderSection: View {
    private let folder = SettingsFolder.shared

    var body: some View {
        Section {
            LabeledContent("Settings Folder") {
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
            Text("Anvil reads its rules, key swaps and mouse settings from rules.json, key-swaps.json and mouse.json in this folder, and saves changes back there. A folder without them starts with the settings you have now.")
                .foregroundStyle(.secondary)
        }
    }
}
