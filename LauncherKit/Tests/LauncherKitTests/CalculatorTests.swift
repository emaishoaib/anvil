import Foundation
import Testing
@testable import LauncherKit

struct CalculatorTests {
    let locale = Locale(identifier: "en_US")

    func answer(_ query: String) -> Answer? {
        Calculator.answer(for: query, locale: locale)
    }

    func output(_ query: String) -> String? {
        answer(query)?.output
    }

    @Test func addsTwoNumbers() {
        #expect(output("2+3") == "5")
    }

    @Test func multiplyingComesBeforeAdding() {
        #expect(output("2 + 3 * 4") == "14")
    }

    @Test func bracketsAreWorkedOutFirst() {
        #expect(output("(2 + 3) * 4") == "20")
        #expect(output("2+2 - (34)") == "-30")
        #expect(output("((1 + 2) * (3 + 4)) / 7") == "3")
    }

    @Test func powersAreWorkedOutFromTheRight() {
        #expect(output("2^3^2") == "512")
    }

    @Test func aMinusInFrontOfAPowerAppliesAfterIt() {
        #expect(output("-2^2") == "-4")
    }

    @Test func timesAndDivideSignsWork() {
        #expect(output("6 × 7") == "42")
        #expect(output("8 ÷ 2") == "4")
    }

    @Test func theLetterXMultiplies() {
        #expect(output("3x4") == "12")
    }

    @Test func aTrailingEqualsSignIsIgnored() {
        #expect(answer("2+2 =")?.input == "2+2")
        #expect(output("2+2=") == "4")
    }

    @Test func decimalsAreRoundedToHideFloatingPointNoise() {
        #expect(output("0.1 + 0.2") == "0.3")
    }

    @Test func largeAnswersAreGroupedButCopiedWithoutSeparators() {
        let answer = answer("1000 * 1000")
        #expect(answer?.output == "1,000,000")
        #expect(answer?.copyText == "1000000")
    }

    @Test func aZeroAnswerHasNoMinusSign() {
        #expect(output("0 * -1") == "0")
    }

    @Test func theInputIsShownAsTyped() {
        #expect(answer("  2+2 - (34) ")?.input == "2+2 - (34)")
    }

    @Test func aSumWithOneKindOfOperatorIsNamedAfterIt() {
        #expect(answer("1+1")?.inputLabel == "Sum")
        #expect(answer("5-3")?.inputLabel == "Difference")
        #expect(answer("6*7")?.inputLabel == "Product")
        #expect(answer("8/2")?.inputLabel == "Quotient")
        #expect(answer("2^8")?.inputLabel == "Power")
    }

    @Test func aSumMixingOperatorsIsAnExpression() {
        #expect(answer("2+2 - (34)")?.inputLabel == "Expression")
    }

    @Test func smallWholeAnswersAreSpelledOut() {
        #expect(answer("1+1")?.outputLabel == "Two")
        #expect(answer("20+1")?.outputLabel == "Twenty-one")
    }

    @Test func otherAnswersAreCalledTheResult() {
        #expect(answer("2+2 - (34)")?.outputLabel == "Result")
        #expect(answer("1/4")?.outputLabel == "Result")
        #expect(answer("1000 * 1000")?.outputLabel == "Result")
    }

    @Test func aPlainNumberIsNotASum() {
        #expect(output("42") == nil)
        #expect(output("-5") == nil)
        #expect(output("(5)") == nil)
    }

    @Test func wordsAreNotSums() {
        #expect(output("xcode") == nil)
    }

    @Test func dividingByZeroHasNoAnswer() {
        #expect(output("1/0") == nil)
    }

    @Test func unfinishedSumsHaveNoAnswer() {
        #expect(output("(2+3") == nil)
        #expect(output("2+3)") == nil)
        #expect(output("2+") == nil)
        #expect(output("1.2.3+1") == nil)
    }
}
