/// The Uninstaller tool's settings in the search bar: whether Anvil has Full Disk Access, which it needs to find and move every leftover, and a row that opens that pane of System Settings.
enum UninstallerCatalog {
    static func settings() -> [Setting] {
        let toolName = Tool.uninstaller.name
        return Setting.subgroup("Full Disk Access", [
            .info("Full Disk Access", id: "uninstaller.fullDiskAccess", toolName: toolName, value: FullDiskAccess.isGranted ? "On" : "Off"),
            .action("Open Full Disk Access Settings", id: "uninstaller.openFullDiskAccess", toolName: toolName) {
                FullDiskAccess.openSettings()
                return nil
            },
        ])
    }
}
