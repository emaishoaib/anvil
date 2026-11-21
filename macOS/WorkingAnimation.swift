import Foundation

/// How Anvil shows that it is working, in the menu bar and wherever something loads: the anvil struck over and over, as it is when the search bar opens, or the anvil glowing orange and cooling back. The choice is saved in the user defaults.
enum WorkingAnimation: String, CaseIterable {
    case strike, glow

    static let savedKey = "general.workingAnimation"
    private static let defaultChoice = WorkingAnimation.strike

    static var current: WorkingAnimation {
        get { UserDefaults.standard.string(forKey: savedKey).flatMap(WorkingAnimation.init(rawValue:)) ?? defaultChoice }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: savedKey) }
    }

    var name: String {
        switch self {
        case .strike: "Strike"
        case .glow: "Glow"
        }
    }
}
