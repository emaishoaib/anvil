import Foundation

/// The folders where apps keep their own files, each found from where the search starts. Most sit inside `~/Library`, one of them inside Application Support, two are the per-user cache and temp folders under `/var/folders`, and the last is the home folder. A folder whose root cannot be found has no URL.
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
    case logs
    case launchAgents
    case applicationScripts
    case crashReporter
    case userCache
    case userTemp
    case home

    public func url(in roots: SearchRoots) -> URL? {
        switch self {
        case .userCache: roots.userCache
        case .userTemp: roots.userTemp
        case .home: roots.home
        default: pathInLibrary.map { roots.library.appending(path: $0, directoryHint: .isDirectory) }
        }
    }

    var holdsFoldersNamedAfterApps: Bool {
        switch self {
        case .applicationSupport, .caches, .logs, .home: true
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

    /// Whether a folder here may be named after the app's vendor rather than the app. The home folder is left out, because a folder there named after a company is more likely the user's own.
    var holdsFoldersNamedAfterVendors: Bool {
        holdsFoldersNamedAfterApps && self != .home
    }

    /// Whether a leftover found here may hold the user's own files, such as a folder in the home folder named after the app, so it should only go to the Trash when the user ticks it.
    var mayHoldUserFiles: Bool {
        self == .home
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
        case .logs: "Logs"
        case .launchAgents: "LaunchAgents"
        case .applicationScripts: "Application Scripts"
        case .crashReporter: "Application Support/CrashReporter"
        case .userCache, .userTemp, .home: nil
        }
    }
}
