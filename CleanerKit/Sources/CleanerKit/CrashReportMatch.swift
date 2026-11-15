/// Whether a file in the CrashReporter folder belongs to an app. macOS names each file after the program that was force quit, followed by an underscore and the Mac's hardware ID, such as `Postman_ADC4BFBE-B5AB-502B-BE84-8760F2526795.plist`.
///
/// The program's name is the app's name or one of its other names, such as `Code` for Visual Studio Code. Everything before the last underscore must equal one of them, ignoring letter case, so `Postman Helper_…` does not belong to Postman.
enum CrashReportMatch {
    static func name(_ name: String, belongsTo app: AppIdentity, in folder: SearchFolder) -> Bool {
        guard folder == .crashReporter, name.lowercased().hasSuffix(".plist"), let underscore = name.lastIndex(of: "_") else { return false }
        let program = name[..<underscore].lowercased()
        return app.allNames.contains { $0.lowercased() == program }
    }
}
