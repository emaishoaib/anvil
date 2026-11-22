import Foundation
import LauncherKit
import Observation

/// The page for choosing the currency table's currencies. With nothing typed it lists the chosen ones in their order, and typing searches every currency that has a rate. A currency that isn't chosen can be added to the end of the list and one that is can be removed, and each change is saved straight away.
@MainActor @Observable final class CurrencyPicker {
    private(set) var chosen = ChosenCurrencies.codes
    private(set) var selected = 0

    func currencies(matching query: String) -> [Currency] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return chosen.map { Currency(code: $0) } }
        guard let rates = CurrencyRatesStore.shared.rates else { return [] }
        return CurrencyChoices.matching(query, rates: rates)
    }

    func selectedCurrency(matching query: String) -> Currency? {
        let currencies = currencies(matching: query)
        return currencies.indices.contains(selected) ? currencies[selected] : nil
    }

    func isChosen(_ currency: Currency) -> Bool {
        chosen.contains(currency.code)
    }

    func select(_ index: Int) {
        selected = index
    }

    func moveSelection(by offset: Int, matching query: String) {
        let count = currencies(matching: query).count
        guard count > 0 else { return }
        selected = min(max(selected + offset, 0), count - 1)
    }

    func canAddSelected(matching query: String) -> Bool {
        selectedCurrency(matching: query).map { !isChosen($0) } ?? false
    }

    func canRemoveSelected(matching query: String) -> Bool {
        selectedCurrency(matching: query).map(isChosen) ?? false
    }

    func addSelected(matching query: String) -> Bool {
        guard let currency = selectedCurrency(matching: query), !isChosen(currency) else { return false }
        chosen.append(currency.code)
        ChosenCurrencies.codes = chosen
        return true
    }

    func removeSelected(matching query: String) -> Bool {
        guard let currency = selectedCurrency(matching: query), isChosen(currency) else { return false }
        chosen.removeAll { $0 == currency.code }
        ChosenCurrencies.codes = chosen
        moveSelection(by: 0, matching: query)
        return true
    }
}
