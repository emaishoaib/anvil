import Foundation
import Testing
@testable import LauncherKit

struct QuantityTests {
    let rates = CurrencyRates(date: "2026-11-22", perDollar: ["USD": 1, "GBP": 0.5, "EGP": 50])

    func pounds(_ amount: Double) -> Quantity { Quantity(amount, in: .currency("GBP")) }
    func dollars(_ amount: Double) -> Quantity { Quantity(amount, in: .currency("USD")) }
    func egyptianPounds(_ amount: Double) -> Quantity { Quantity(amount, in: .currency("EGP")) }
    func unit(_ amount: Double, _ name: String) -> Quantity { Quantity(amount, in: .unit(UnitCatalog.entry(named: name)!)) }

    func combine(_ left: Quantity, _ operation: ExpressionToken, _ right: Quantity) -> Quantity? {
        left.combined(with: right, by: operation, rates: rates)
    }

    @Test func aPlainNumberTakesTheCurrencyItIsTakenAwayFrom() {
        let converted = pounds(150).converted(to: .currency("EGP"), rates: rates)!
        #expect(combine(converted, .minus, Quantity(8400)) == egyptianPounds(6600))
    }

    @Test func aPlainNumberOnTheLeftTakesTheRightsMeasure() {
        #expect(combine(Quantity(2), .plus, unit(3, "km")) == unit(5, "km"))
    }

    @Test func theRightSideIsConvertedIntoTheLeftSidesCurrency() {
        #expect(combine(pounds(20), .plus, dollars(15)) == pounds(27.5))
    }

    @Test func theRightSideIsConvertedIntoTheLeftSidesUnit() {
        #expect(combine(unit(5, "km"), .plus, unit(500, "m")) == unit(5.5, "km"))
    }

    @Test func amountsOfDifferentKindsDoNotCombine() {
        #expect(combine(unit(5, "kg"), .plus, unit(3, "m")) == nil)
        #expect(combine(unit(5, "kg"), .plus, pounds(3)) == nil)
    }

    @Test func multiplyingOrDividingByAPlainNumberKeepsTheMeasure() {
        #expect(combine(pounds(90), .divide, Quantity(3)) == pounds(30))
        #expect(combine(Quantity(3), .times, unit(2, "km")) == unit(6, "km"))
    }

    @Test func twoLengthsMultiplyIntoAnArea() {
        #expect(combine(unit(150, "cm"), .times, unit(180, "cm")) == unit(27_000, "sq cm"))
        #expect(combine(unit(2, "km"), .times, unit(3, "km")) == unit(6, "sq km"))
    }

    @Test func theRightLengthIsConvertedIntoTheLeftLengthsUnitBeforeMultiplying() {
        #expect(combine(unit(3, "ft"), .times, unit(1, "yd")) == unit(9, "sq ft"))
    }

    @Test func otherMeasuredAmountsDoNotMultiply() {
        #expect(combine(unit(2, "kg"), .times, unit(3, "kg")) == nil)
        #expect(combine(unit(2, "m"), .times, unit(3, "kg")) == nil)
        #expect(combine(unit(2, "sq m"), .times, unit(3, "m")) == nil)
        #expect(combine(pounds(2), .times, pounds(3)) == nil)
    }

    @Test func dividingLikeAmountsGivesAPlainNumber() {
        #expect(combine(pounds(300), .divide, dollars(40)) == Quantity(15))
    }

    @Test func aPlainNumberCannotBeDividedByAMeasuredAmount() {
        #expect(combine(Quantity(10), .divide, unit(2, "km")) == nil)
    }

    @Test func plainNumbersTakeAnyPower() {
        #expect(combine(Quantity(2), .power, Quantity(3)) == Quantity(8))
    }

    @Test func aLengthSquaredIsAnArea() {
        #expect(combine(unit(3, "m"), .power, Quantity(2)) == unit(9, "sq m"))
    }

    @Test func theSquareRootOfAnAreaIsALength() {
        #expect(combine(unit(9, "sq cm"), .power, Quantity(0.5)) == unit(3, "cm"))
    }

    @Test func otherPowersOfUnitsDoNotWork() {
        #expect(combine(unit(2, "m"), .power, Quantity(3)) == nil)
        #expect(combine(unit(2, "kg"), .power, Quantity(2)) == nil)
        #expect(combine(unit(4, "acres"), .power, Quantity(0.5)) == nil)
        #expect(combine(pounds(4), .power, Quantity(0.5)) == nil)
        #expect(combine(Quantity(2), .power, unit(2, "m")) == nil)
    }

    @Test func oneCurrencyNeedsNoRates() {
        #expect(pounds(20).combined(with: pounds(15), by: .plus, rates: nil) == pounds(35))
    }

    @Test func twoCurrenciesNeedRates() {
        #expect(pounds(20).combined(with: dollars(15), by: .plus, rates: nil) == nil)
    }

    @Test func aCurrencyMissingFromTheRatesDoesNotConvert() {
        #expect(pounds(20).converted(to: .currency("JPY"), rates: rates) == nil)
    }

    @Test func aPlainNumberHasNothingToConvertFrom() {
        #expect(Quantity(5).converted(to: .currency("USD"), rates: rates) == nil)
    }

    @Test func unitsOfDifferentKindsDoNotConvert() {
        #expect(unit(5, "kg").converted(to: .unit(UnitCatalog.entry(named: "m")!), rates: rates) == nil)
    }
}
