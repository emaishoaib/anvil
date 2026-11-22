import Foundation
import Testing
@testable import LauncherKit

struct ExpressionParserTests {
    let rates = CurrencyRates(date: "2026-11-22", perDollar: ["USD": 1, "GBP": 0.5, "EUR": 0.25, "EGP": 50, "JPY": 150])

    func parse(_ query: String, rates: CurrencyRates? = nil) -> Quantity? {
        guard let tokens = ExpressionToken.tokens(in: query) else { return nil }
        var parser = ExpressionParser(tokens: tokens, rates: rates)
        return parser.parse()
    }

    func money(_ amount: Double, _ code: String) -> Quantity {
        Quantity(amount, in: .currency(code))
    }

    func unit(_ amount: Double, _ name: String) -> Quantity {
        Quantity(amount, in: Measure(named: name))
    }

    func isClose(_ query: String, to expected: Quantity) -> Bool {
        guard let parsed = parse(query, rates: rates), parsed.measure == expected.measure else { return false }
        return abs(parsed.amount - expected.amount) < 1e-9
    }

    @Test func aConvertedAmountInBracketsCanBeSubtractedFrom() {
        #expect(parse("(150 GBP to EGP) - 8400", rates: rates) == money(6600, "EGP"))
    }

    @Test func differentCurrenciesAddUpInTheFirstOne() {
        #expect(parse("£20 + $15", rates: rates) == money(27.5, "GBP"))
    }

    @Test func differentUnitsAddUpInTheFirstOne() {
        #expect(parse("5 km + 500 m") == unit(5.5, "km"))
    }

    @Test func aConversionAtTheEndChangesTheWholeSum() {
        #expect(parse("5 km + 500 m to m") == unit(5500, "m"))
    }

    @Test func aConvertedAmountCanBeDivided() {
        #expect(parse("(3 hours to minutes) / 4") == unit(45, "min"))
    }

    @Test func symbolsWorkBeforeOrAfterTheAmount() {
        #expect(parse("$100 in egp", rates: rates) == money(5000, "EGP"))
        #expect(parse("25€ to $", rates: rates) == money(100, "USD"))
    }

    @Test func aCurrencyCodeCanComeBeforeTheAmount() {
        #expect(parse("usd 100 to gbp", rates: rates) == money(50, "GBP"))
    }

    @Test func theWordBeforeTheTargetCanBeLeftOut() {
        #expect(parse("100 usd egp", rates: rates) == money(5000, "EGP"))
        #expect(parse("100 usd = gbp", rates: rates) == money(50, "GBP"))
    }

    @Test func amountsCanHaveThousandsSeparators() {
        #expect(parse("15,000 jpy to usd", rates: rates) == money(100, "USD"))
    }

    @Test func inchesAreToldApartFromIn() {
        #expect(isClose("12 in to cm", to: unit(30.48, "cm")))
        #expect(isClose("5 ft in m", to: unit(1.524, "m")))
    }

    @Test func unitsOfMoreThanOneWordWork() {
        #expect(parse("2 sq km to ha") == unit(200, "ha"))
        #expect(isClose("8 fl oz to ml", to: unit(236.5882365, "ml")))
    }

    @Test func unitsWithSlashesOrDigitsStayWhole() {
        #expect(isClose("36 km/h to m/s", to: unit(10, "m/s")))
        #expect(parse("10000 m2 to ha") == unit(1, "ha"))
        #expect(parse("10 km/2") == unit(5, "km"))
    }

    @Test func theLetterXStillMultiplies() {
        #expect(parse("3x4") == Quantity(12))
        #expect(parse("£20 x 3", rates: rates) == money(60, "GBP"))
    }

    @Test func differentKindsOfAmountDoNotCombine() {
        #expect(parse("5 kg + 3 m") == nil)
        #expect(parse("5 kg + £3", rates: rates) == nil)
    }

    @Test func aPlainNumberHasNothingToConvert() {
        #expect(parse("5 to usd", rates: rates) == nil)
    }

    @Test func changingCurrencyNeedsRates() {
        #expect(parse("£20 + $15") == nil)
        #expect(parse("£20 + £15") == money(35, "GBP"))
    }

    @Test func unknownWordsAreNotAmounts() {
        #expect(parse("5 xyz") == nil)
        #expect(parse("xcode") == nil)
        #expect(parse("100 usd to xyz", rates: rates) == nil)
    }
}
