import Foundation
import Testing
@testable import LauncherKit

struct UnitConversionTests {
    let locale = Locale(identifier: "en_US")

    func answer(_ query: String) -> Answer? {
        Calculator.answer(for: query, locale: locale)
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

    @Test func informalSpellingsOfMassesWork() {
        #expect(output("1 kg to gm") == "1,000 g")
        #expect(output("2 kgs in gms") == "2,000 g")
        #expect(output("500 gr to kg") == "0.5 kg")
        #expect(output("1000 mgs to g") == "1 g")
    }

    @Test func informalSpellingsOfLengthsWork() {
        #expect(output("3 kms to mtrs") == "3,000 m")
        #expect(output("10 mms in cms") == "1 cm")
        #expect(output("1 mtr to cm") == "100 cm")
    }

    @Test func informalSpellingsOfVolumesWork() {
        #expect(output("2 ltr to ml") == "2,000 mL")
        #expect(output("500 mls in ltrs") == "0.5 L")
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

    @Test func smallerSquareUnitsConvert() {
        #expect(output("1 m2 to cm2") == "10,000 cm²")
        #expect(output("1 sq cm to sq mm") == "100 mm²")
        #expect(output("1 square yards to square inches") == "1,296 in²")
        #expect(output("1 in2") == "6.4516 cm²")
        #expect(output("1 sq yd") == "0.83612736 m²")
    }

    @Test func eachUnitHasADefaultTarget() {
        #expect(output("1 mile") == "1.609344 km")
        #expect(output("2 hours") == "120 minutes")
        #expect(output("1 gb") == "1,000 MB")
    }

    @Test func theCopiedAnswerIsAPlainNumber() {
        #expect(answer("1kg to g")?.copyText == "1000")
    }

    @Test func aSumOfUnitsStaysInTheFirstUnit() {
        #expect(output("5 km + 500 m") == "5.5 km")
        #expect(answer("5 km + 500 m")?.inputLabel == "Sum")
        #expect(answer("5 km + 500 m")?.outputLabel == "Kilometres")
    }

    @Test func aSumOfUnitsCanBeConvertedAtTheEnd() {
        #expect(output("(3 hours to minutes) / 4") == "45 minutes")
    }

    @Test func twoLengthsMultipliedShowAsAnArea() {
        #expect(output("150cm * 180cm to m2") == "2.7 m²")
        #expect(answer("150cm * 180cm")?.outputLabel == "Square Centimetres")
        #expect(answer("2kg * 3kg") == nil)
    }

    @Test func powersOfLengthsAndAreasShowInTheirUnits() {
        #expect(output("(3.3m2 ^ 0.5) to cm") == "181.6590212458 cm")
        #expect(output("3m ^ 2") == "9 m²")
    }

    @Test func theSideOfAnAreaCanBeConvertedAndThenDivided() {
        #expect(output("(3.3m2 ^ 0.5) to cm / 8") == "22.7073776557 cm")
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
