import ServiceManagement

enum LoginItem {
    static func addOnFirstLaunch() {
        guard SMAppService.mainApp.status == .notRegistered else { return }
        try? SMAppService.mainApp.register()
    }
}
