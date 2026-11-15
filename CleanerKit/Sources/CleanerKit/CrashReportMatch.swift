/// Whether a file in the CrashReporter folder belongs to an app. macOS names each file after the program that was force quit, followed by an underscore and the Mac's hardware ID, such as `Postman_ADC4BFBE-B5AB-502B-BE84-8760F2526795.plist`.
///
/// The program's name is either the app's name or the name of the executable inside it, such as `Code` for Visual Studio Code. Everything before the last underscore must equal one of the two, ignoring letter case, so `Postman Helper_…` does not belong to Postman.
enum CrashReportMatch {
    static func name(_ name: String, belongsTo app: AppIdentity, in folder: SearchFolder) -> Bool {
        guard folder == .crashReporter, name.lowercased().hasSuffix(".plist"), let underscore = name.lastIndex(of: "_") else { return false }
        let program = name[..<underscore].lowercased()
        return [app.name, app.executableName].compactMap { $0?.lowercased() }.contains(program)
    }
}
