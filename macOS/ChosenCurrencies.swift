import Foundation
import LauncherKit

/// The currencies the currency table lists, in the order they were chosen. They are saved in the user defaults, which the settings folder mirrors into the General section of the settings file. Reading the list before anything is saved saves the starting list, so it shows up in the file ready to edit, and codes typed there in lowercase are read in capitals.
enum ChosenCurrencies {
    static let savedKey = "launcher.currencies"

    static var codes: [String] {
        get {
            guard let saved = UserDefaults.standard.stringArray(forKey: savedKey) else {
                let starting = CurrencyChoices.startingCodes()
                UserDefaults.standard.set(starting, forKey: savedKey)
                return starting
            }
            return saved.map { $0.uppercased() }
        }
        set { UserDefaults.standard.set(newValue, forKey: savedKey) }
    }
}
