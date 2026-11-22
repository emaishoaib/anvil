/// The Launcher's settings in the search bar: importing and exporting quick links, and the currencies the currency table lists. The file panels open through the search bar, and the message they return shows in its footer. Quick links themselves are already created, edited and deleted from the search bar, so they have no rows here.
enum LauncherCatalog {
    static func settings() -> [Setting] {
        Setting.subgroup("Quick Links", [
            .action("Import Quick Links", id: "launcher.importQuickLinks", toolName: Tool.launcher.name) {
                SearchBar.shared.presentModal(QuickLinkTransfer.importFile)
            },
            .action("Export Quick Links", id: "launcher.exportQuickLinks", toolName: Tool.launcher.name, isDisabled: QuickLinkLibrary.shared.links.isEmpty) {
                SearchBar.shared.presentModal(QuickLinkTransfer.exportFile)
            },
        ]) + Setting.subgroup("Currencies", CurrenciesCatalog.settings())
    }
}
