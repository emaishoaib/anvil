import AppKit
import Observation

@Observable final class RulesFolder {
    static let shared = RulesFolder()

    private(set) var url = RuleStorage.folder

    var displayPath: String {
        url.map { ($0.path as NSString).abbreviatingWithTildeInPath } ?? "Anvil's settings"
    }

    func choose() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.message = "Choose the folder that holds rules.json and key-swaps.json"
        guard panel.runModal() == .OK, let chosen = panel.url else { return }
        use(chosen)
    }

    func useSettings() {
        use(nil)
    }

    private func use(_ folder: URL?) {
        RuleStorage.folder = folder
        url = folder
        RuleLibrary.shared.reload()
        KeySwapLibrary.shared.reload()
    }
}
