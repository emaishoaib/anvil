import Foundation
import LauncherKit

/// The currencies the currency table lists, in the order they were chosen. They are saved in the user defaults, which the settings folder mirrors into the General section of the settings file. Until it is changed it is the starting list, which is written to the file like every other default so it is there ready to edit, and codes typed there in lowercase are read in capitals.
enum ChosenCurrencies {
    static let savedKey = "launcher.currencies"

    static var codes: [String] {
        get { (UserDefaults.standard.stringArray(forKey: savedKey) ?? CurrencyChoices.startingCodes()).map { $0.uppercased() } }
        set { UserDefaults.standard.set(newValue, forKey: savedKey) }
    }
}
