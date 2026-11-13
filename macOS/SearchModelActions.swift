import AppKit
import LauncherKit

extension SearchModel {
    func run(_ action: QuickLinkAction) -> Bool {
        guard case .quickLink(let link) = selectedResult else { return false }
        closeActions()
        switch action {
        case .open:
            open(.quickLink(link))
        case .openWith:
            showActions(for: link, page: .openWith)
        case .edit:
            _ = editSelectedLink()
        case .duplicate:
            _ = duplicateSelectedLink()
        case .resetRanking:
            SavedLaunchCounts.reset(link.launchKey)
            reloadResults()
        case .copyName:
            copy(link.name)
            SearchBar.shared.hide()
        case .copyLink:
            copy(link.link)
            SearchBar.shared.hide()
        case .delete:
            showActions(for: link, page: .confirmDelete)
        }
        return true
    }

    func performSelectedAction() {
        guard let item = actionPanel?.selectedItem else { return }
        perform(item)
    }

    func perform(_ item: ActionPanel.Item) {
        let link = actionPanel?.link
        switch item {
        case .action(let action):
            _ = run(action)
        case .app(let app):
            guard let link else { return }
            closeActions()
            open(link, filling: arguments.values, in: app)
            SearchBar.shared.hide()
        case .confirmDelete:
            guard let link else { return }
            QuickLinkLibrary.shared.delete(link)
            closeActions()
            reloadResults()
        case .cancel:
            closeActions()
        case .anvil(let action):
            closeActions()
            run(action)
        }
    }

    private func run(_ action: AnvilAction) {
        switch action {
        case .settings:
            SearchBar.shared.hide()
            SettingsWindow.shared.show()
        case .checkForUpdates:
            SearchBar.shared.hide()
            AppUpdater.shared.check()
        case .quit:
            NSApplication.shared.terminate(nil)
        }
    }

    func backInActions() {
        guard let actionPanel, actionPanel.page == .openWith else { return closeActions() }
        actionPanel.show(.actions)
    }
}
