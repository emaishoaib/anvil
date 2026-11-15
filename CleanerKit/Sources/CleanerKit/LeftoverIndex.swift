import Foundation

/// The files and folders named after each installed app, found in one walk of the Mac, as `WalkSearch` finds them. Each app is known here only by its bundle ID and names, because looking through every app for its helpers and app groups would take too long. Those are still searched for once an app is picked, as `RemovalPlan` does. An app's own bundle is not among its finds, and an app without a bundle ID has none.
public struct LeftoverIndex: Sendable {
    private let findsByAppURL: [URL: [URL]]

    public init(appURLs: [URL], walking folders: [URL] = DiskWalk.macFolders) {
        let identities = appURLs.compactMap { url in AppIdentity(appAt: url).map { (url: url, identity: $0) } }
        let matches = WalkSearch.matches(of: identities.map(\.identity), in: folders)
        findsByAppURL = Dictionary(identities.map { app in
            let ownPath = app.url.standardizedFileURL.pathComponents
            return (app.url, (matches[app.identity] ?? []).filter { $0.standardizedFileURL.pathComponents != ownPath })
        }, uniquingKeysWith: +)
    }

    public func finds(forAppAt appURL: URL) -> [URL] {
        findsByAppURL[appURL] ?? []
    }
}
