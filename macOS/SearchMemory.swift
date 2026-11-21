import Foundation

/// How long the search bar remembers where you left it. Opened again within that time, it comes back as it was, with the same page, text and selection. After that, or when set to never, it opens fresh on the launcher. The choice is saved in the user defaults.
enum SearchMemory: String, CaseIterable {
    case never, tenSeconds, thirtySeconds, oneMinute, fiveMinutes, fifteenMinutes

    static let savedKey = "launcher.searchMemory"
    private static let defaultChoice = SearchMemory.oneMinute

    static var current: SearchMemory {
        get { UserDefaults.standard.string(forKey: savedKey).flatMap(SearchMemory.init(rawValue:)) ?? defaultChoice }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: savedKey) }
    }

    var duration: Duration {
        switch self {
        case .never: .zero
        case .tenSeconds: .seconds(10)
        case .thirtySeconds: .seconds(30)
        case .oneMinute: .seconds(60)
        case .fiveMinutes: .seconds(5 * 60)
        case .fifteenMinutes: .seconds(15 * 60)
        }
    }

    var name: String {
        switch self {
        case .never: "Never"
        case .tenSeconds: "10 seconds"
        case .thirtySeconds: "30 seconds"
        case .oneMinute: "1 minute"
        case .fiveMinutes: "5 minutes"
        case .fifteenMinutes: "15 minutes"
        }
    }
}
