import Foundation
import Testing
@testable import LauncherKit

struct UnitConversionTests {
    let locale = Locale(identifier: "en_US")

    func answer(_ query: String) -> Answer? {
        UnitConversion.answer(for: query, locale: locale)
    }

    func output(_ query: String) -> String? {
        answer(query)?.output
    }

    @Test func convertsKilogramsToGrams() {
        #expect(output("1kg to g") == "1,000 g")
    }

    @Test func labelsNameBothUnits() {
        let answer = answer("1kg to g")
        #expect(answer?.input == "1kg to g")
        #expect(answer?.inputLabel == "Kilograms")
        #expect(answer?.outputLabel == "Grams")
    }

    @Test func daysOnTheirOwnBecomeWeeks() {
        #expect(output("30 days") == "4.2857142857 weeks")
        #expect(answer("30 days")?.outputLabel == "Weeks")
    }

    @Test func oneOfATimeUnitIsSingular() {
        #expect(output("7 days to weeks") == "1 week")
        #expect(output("1 week") == "7 days")
    }

    @Test func wordsForUnitsWork() {
        #expect(output("5 kilos in pounds") == "11.0231131092 lb")
    }

    @Test func temperaturesConvertWithTheirOffsets() {
        #expect(output("100 c to f") == "212 °F")
        #expect(output("-40°c to °f") == "-40 °F")
        #expect(output("100 c") == "212 °F")
    }

    @Test func inchesAreTellApartFromIn() {
        #expect(output("12 in to cm") == "30.48 cm")
        #expect(output("5 ft in m") == "1.524 m")
    }

    @Test func unitsOfMoreThanOneWordWork() {
        #expect(output("8 fl oz to ml") == "236.5882365 mL")
        #expect(output("1 square miles in sq km") == "2.5899881103 km²")
    }

    @Test func eachUnitHasADefaultTarget() {
        #expect(output("1 mile") == "1.609344 km")
        #expect(output("2 hours") == "120 minutes")
        #expect(output("1 gb") == "1,000 MB")
    }

    @Test func theCopiedAnswerIsAPlainNumber() {
        #expect(answer("1kg to g")?.copyText == "1000")
    }

    @Test func unitsThatMeasureDifferentThingsDoNotConvert() {
        #expect(answer("5 kg to m") == nil)
    }

    @Test func otherTextIsNotAConversion() {
        #expect(answer("30 days from now") == nil)
        #expect(answer("100 usd to eur") == nil)
        #expect(answer("safari") == nil)
        #expect(answer("5") == nil)
        #expect(answer("kg") == nil)
    }
}
