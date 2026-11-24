import Foundation
import Testing
@testable import LauncherKit

struct CurrencyTableTests {
    let rates = CurrencyRates(date: "2026-11-22", perDollar: ["USD": 1, "EUR": 0.9, "GBP": 0.8, "JPY": 150, "EGP": 50])

    func table(_ query: String, locale: Locale = Locale(identifier: "en_US")) -> CurrencyTable? {
        CurrencyTable(for: query, codes: CurrencyChoices.startingCodes(locale: locale), rates: rates, locale: locale)
    }

    func codes(_ query: String, locale: Locale = Locale(identifier: "en_US")) -> [String]? {
        table(query, locale: locale)?.rows.map(\.code)
    }

    func amount(_ query: String, in code: String) -> String? {
        table(query)?.rows.first { $0.code == code }?.amount.replacingOccurrences(of: "\u{00A0}", with: " ")
    }

    @Test func anAmountIsListedInTheTopCurrenciesThatHaveRates() {
        #expect(codes("300 gbp") == ["USD", "EUR", "JPY"])
        #expect(amount("300 gbp", in: "USD") == "$375.00")
        #expect(amount("300 gbp", in: "JPY") == "¥56,250")
    }

    @Test func theTypedCurrencyIsLeftOut() {
        #expect(codes("100 usd") == ["EUR", "JPY", "GBP"])
    }

    @Test func aTargetAtTheEndLeavesTheTableAsItWas() {
        #expect(table("300 gbp to usd") == table("300 gbp"))
        #expect(table("300 gbp in eur") == table("300 gbp"))
    }

    @Test func aSumIsListedFromItsResult() {
        #expect(!codes("(150 GBP to EGP) - 8400")!.contains("EGP"))
        #expect(amount("(150 GBP to EGP) - 8400", in: "USD") == "$19.50")
    }

    @Test func aSumThatCarriesOnAfterAConversionIsListedFromItsResult() {
        #expect(table("150 GBP to EGP - 8400") == table("(150 GBP to EGP) - 8400"))
    }

    @Test func theChosenCurrenciesAreListedInTheirOrder() {
        let table = CurrencyTable(for: "300 gbp", codes: ["EGP", "GBP", "USD"], rates: rates, locale: Locale(identifier: "en_US"))
        #expect(table?.rows.map(\.code) == ["EGP", "USD"])
    }

    @Test func rowsCarryTheCurrencysNameAndAPlainNumberToCopy() {
        let row = table("300 gbp")?.rows.first
        #expect(row?.name == "US Dollar")
        #expect(row?.copyText == "375.00")
    }

    @Test func onlyMoneyHasATable() {
        #expect(table("5 km") == nil)
        #expect(table("2 + 3") == nil)
        #expect(table("safari") == nil)
        #expect(table("£300 / $40") == nil)
    }

    @Test func thereIsNoTableWithoutRates() {
        #expect(CurrencyTable(for: "300 gbp", codes: ["USD"], rates: nil, locale: Locale(identifier: "en_US")) == nil)
    }
}
