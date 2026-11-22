import Foundation
import Testing
@testable import LauncherKit

struct CurrencyConversionTests {
    let locale = Locale(identifier: "en_US")
    let rates = CurrencyRates(date: "2026-11-12", perDollar: ["USD": 1, "EUR": 0.9, "GBP": 0.8, "EGP": 50, "JPY": 150])

    func answer(_ query: String) -> Answer? {
        Calculator.answer(for: query, rates: rates, locale: locale)
    }

    func output(_ query: String) -> String? {
        answer(query)?.output.replacingOccurrences(of: "\u{00A0}", with: " ")
    }

    @Test func convertsBetweenTwoCodes() {
        #expect(output("100 usd to eur") == "€90.00")
    }

    @Test func goesThroughTheDollarForOtherPairs() {
        #expect(output("80 gbp in eur") == "€90.00")
    }

    @Test func symbolsWorkBeforeOrAfterTheAmount() {
        #expect(output("$100 in egp") == "EGP 5,000.00")
        #expect(output("90€ to $") == "$100.00")
    }

    @Test func theWordBetweenCurrenciesCanBeLeftOut() {
        #expect(output("100 usd eur") == "€90.00")
    }

    @Test func amountsCanHaveThousandsSeparators() {
        #expect(output("15,000 jpy to usd") == "$100.00")
    }

    @Test func currencyNamesWork() {
        #expect(output("100 dollars in euros") == "€90.00")
    }

    @Test func withoutATargetItConvertsToTheLocalCurrency() {
        #expect(output("90 eur") == "$100.00")
        #expect(answer("100 usd") == nil)
    }

    @Test func labelsNameBothCurrencies() {
        let answer = answer("100 usd to eur")
        #expect(answer?.input == "100 usd to eur")
        #expect(answer?.inputLabel == "US Dollar")
        #expect(answer?.outputLabel == "Euro")
    }

    @Test func theCopiedAnswerIsAPlainNumber() {
        #expect(answer("100 usd to egp")?.copyText == "5000.00")
    }

    @Test func otherTextIsNotAConversion() {
        #expect(answer("100 xyz to usd") == nil)
        #expect(answer("safari") == nil)
        #expect(answer("usd") == nil)
    }

    @Test func aConvertedAmountCanBeUsedInASum() {
        let answer = answer("(150 GBP to EGP) - 8400")
        #expect(output("(150 GBP to EGP) - 8400") == "EGP 975.00")
        #expect(answer?.inputLabel == "Difference")
        #expect(answer?.outputLabel == "Egyptian Pound")
    }

    @Test func aSumOfCurrenciesIsInTheFirstOne() {
        #expect(output("£20 + $16") == "£32.80")
    }

    @Test func aCurrencyWithoutARateHasNoAnswer() {
        #expect(answer("100 usd to chf") == nil)
    }

    @Test func ratesAreReadFromTheServiceWithCodesInCapitals() throws {
        let json = Data(#"{"date":"2026-11-12","usd":{"usd":1,"egp":53.5,"eur":0.9}}"#.utf8)
        let rates = try CurrencyRates(json: json)
        #expect(rates == CurrencyRates(date: "2026-11-12", perDollar: ["USD": 1, "EGP": 53.5, "EUR": 0.9]))
    }
}
