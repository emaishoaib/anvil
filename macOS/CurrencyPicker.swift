import Foundation
import LauncherKit
import Observation

/// The page for choosing the currency table's currencies. With nothing typed it lists the chosen ones in their order, and typing searches every currency that has a rate. A currency that isn't chosen can be added to the end of the list, one that is can be removed, and the chosen ones can be moved up and down the list. Each change is saved straight away.
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
        remove(currency, matching: query)
        return true
    }

    func canMoveSelected(matching query: String) -> Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty && chosen.count > 1
    }

    /// Moves the selected currency one place up or down the chosen list, keeping it selected. Whether it moved, which it can't past either end or while searching.
    func moveSelected(by offset: Int, matching query: String) -> Bool {
        guard canMoveSelected(matching: query), chosen.indices.contains(selected + offset) else { return false }
        move(from: selected, to: selected + offset)
        return true
    }

    /// Moves a chosen currency to another place in the list, keeping the same currency selected.
    func move(from source: Int, to destination: Int) {
        guard source != destination, chosen.indices.contains(source), chosen.indices.contains(destination) else { return }
        let selectedCode = chosen.indices.contains(selected) ? chosen[selected] : nil
        chosen.insert(chosen.remove(at: source), at: destination)
        ChosenCurrencies.codes = chosen
        if let selectedCode, let index = chosen.firstIndex(of: selectedCode) { selected = index }
    }

    func remove(_ currency: Currency, matching query: String) {
        chosen.removeAll { $0 == currency.code }
        ChosenCurrencies.codes = chosen
        moveSelection(by: 0, matching: query)
    }
}
