import Foundation

/// Saves a screenshot to the Desktop as a PNG file named the way the Mac names its own screenshots, after the moment it is saved. An existing file is never replaced. Whether it was saved.
enum DesktopScreenshot {
    static func save(_ png: Data) -> Bool {
        guard let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else { return false }
        let file = desktop.appending(path: "\(name(at: .now)).png")
        return (try? png.write(to: file, options: .withoutOverwriting)) != nil
    }

    private static func name(at moment: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "'Screenshot' yyyy-MM-dd 'at' HH.mm.ss"
        return formatter.string(from: moment)
    }
}
