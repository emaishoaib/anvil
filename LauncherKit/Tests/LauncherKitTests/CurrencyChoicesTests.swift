import Foundation
import Testing
@testable import LauncherKit

struct CurrencyChoicesTests {
    let locale = Locale(identifier: "en_US")
    let rates = CurrencyRates(date: "2026-11-22", perDollar: ["USD": 1, "EUR": 0.9, "GBP": 0.8, "EGP": 50, "JPY": 150, "BTC": 0.00001])

    func codes(_ query: String) -> [String] {
        CurrencyChoices.matching(query, rates: rates, locale: locale).map(\.code)
    }

    @Test func theStartingListIsTheMostTradedCurrencies() {
        #expect(CurrencyChoices.startingCodes(locale: locale) == ["USD", "EUR", "JPY", "GBP", "CNY", "AUD", "CAD", "CHF", "HKD", "SGD"])
    }

    @Test func theMacsOwnCurrencyEndsTheStartingListWhenItIsNotATopOne() {
        #expect(CurrencyChoices.startingCodes(locale: Locale(identifier: "en_EG")).last == "EGP")
        #expect(CurrencyChoices.startingCodes(locale: Locale(identifier: "en_GB")).count == 10)
    }

    @Test func aCurrencyIsFoundByItsCodeInAnyCase() {
        #expect(codes("egp") == ["EGP"])
        #expect(codes("EUR").first == "EUR")
    }

    @Test func aCurrencyIsFoundByItsName() {
        #expect(codes("egyptian") == ["EGP"])
        #expect(codes("pound") == ["GBP", "EGP"])
    }

    @Test func codesComeBeforeNames() {
        #expect(Array(codes("e").prefix(2)) == ["EGP", "EUR"])
        #expect(codes("u").first == "USD")
    }

    @Test func onlyCurrenciesWithARateAreFound() {
        #expect(codes("chf").isEmpty)
    }

    @Test func codesThatAreNotCurrenciesAreLeftOut() {
        #expect(codes("btc").isEmpty)
    }

    @Test func nothingTypedFindsNothing() {
        #expect(codes(" ").isEmpty)
    }

    @Test func eachFoundCurrencyCarriesItsName() {
        #expect(CurrencyChoices.matching("egp", rates: rates, locale: locale).first?.name == "Egyptian Pound")
    }
}
