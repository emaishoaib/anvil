import Foundation

/// The folders where apps keep their own files, each found from where the search starts. Most sit inside `~/Library`, along with `~/Library` itself and two folders inside Application Support, two are the per-user cache and temp folders under `/var/folders`, and the last is the home folder. A folder whose root cannot be found has no URL.
public enum SearchFolder: CaseIterable, Sendable {
    case applicationSupport
    case caches
    case preferences
    case preferencesByHost
    case containers
    case groupContainers
    case savedApplicationState
    case httpStorages
    case webKit
    case cookies
    case logs
    case launchAgents
    case applicationScripts
    case crashReporter
    case updaterCaches
    case library
    case userCache
    case userTemp
    case home

    public func url(in roots: SearchRoots) -> URL? {
        switch self {
        case .library: roots.library
        case .userCache: roots.userCache
        case .userTemp: roots.userTemp
        case .home: roots.home
        default: pathInLibrary.map { roots.library.appending(path: $0, directoryHint: .isDirectory) }
        }
    }

    var holdsFoldersNamedAfterApps: Bool {
        switch self {
        case .applicationSupport, .caches, .logs, .updaterCaches, .library, .home: true
        default: false
        }
    }

    /// Whether a file here may be named after the app followed by a file extension, such as `Folx.log` in Logs or `TeXShop.plist` in Preferences. The home folder is left out, because a file there named after an app is more likely the user's own.
    var holdsFilesNamedAfterApps: Bool {
        switch self {
        case .applicationSupport, .caches, .logs, .preferences: true
        default: false
        }
    }

    /// Whether a folder here may be named after the app's vendor rather than the app. The home folder and `~/Library` itself are left out, because a vendor's folder there, such as `~/Library/Google`, is shared by the vendor's apps or is the user's own.
    var holdsFoldersNamedAfterVendors: Bool {
        switch self {
        case .applicationSupport, .caches, .logs: true
        default: false
        }
    }

    /// Whether a leftover found here may hold the user's own files, so it should only go to the Trash when the user ticks it. A folder in the home folder named after the app may be the user's, and one directly in `~/Library`, such as `~/Library/TeXShop`, often holds templates the user made.
    var mayHoldUserFiles: Bool {
        switch self {
        case .home, .library: true
        default: false
        }
    }

    private var pathInLibrary: String? {
        switch self {
        case .applicationSupport: "Application Support"
        case .caches: "Caches"
        case .preferences: "Preferences"
        case .preferencesByHost: "Preferences/ByHost"
        case .containers: "Containers"
        case .groupContainers: "Group Containers"
        case .savedApplicationState: "Saved Application State"
        case .httpStorages: "HTTPStorages"
        case .webKit: "WebKit"
        case .cookies: "Cookies"
        case .logs: "Logs"
        case .launchAgents: "LaunchAgents"
        case .applicationScripts: "Application Scripts"
        case .crashReporter: "Application Support/CrashReporter"
        case .updaterCaches: "Application Support/Caches"
        case .library, .userCache, .userTemp, .home: nil
        }
    }
}
