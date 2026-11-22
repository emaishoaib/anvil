import LauncherKit

/// The currency table's rows in the Launcher settings: a row at the top that opens the currency picker, then a row per chosen currency in its order that removes it.
enum CurrenciesCatalog {
    static let explanation = "Choose the currencies an amount of money is shown in under its answer."

    static func settings() -> [Setting] {
        [addCurrency] + ChosenCurrencies.codes.map { row(for: Currency(code: $0)) }
    }

    private static var addCurrency: Setting {
        .action("Add Currency", id: "currencies.add", toolName: Tool.launcher.name, subtitle: explanation) {
            SearchBar.shared.showCurrencyPicker()
            return nil
        }
    }

    private static func row(for currency: Currency) -> Setting {
        .action("\(currency.name) (\(currency.code))", id: "currency.\(currency.code)", toolName: Tool.launcher.name, actionTitle: "Remove Currency") {
            ChosenCurrencies.codes.removeAll { $0 == currency.code }
            return nil
        }
    }
}
