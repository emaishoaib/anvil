import Foundation

enum UnitCatalog {
    private static let secondsPerDay = 86_400.0
    private static let daysPerMonth = 30.436875
    private static let daysPerYear = 365.2425

    private static let kelvinPerFahrenheit = 5.0 / 9.0
    private static let fahrenheitAtAbsoluteZero = 459.67

    private static func duration(_ symbol: String, days: Double) -> UnitDuration {
        UnitDuration(symbol: symbol, converter: UnitConverterLinear(coefficient: days * secondsPerDay))
    }

    private static func exactly(_ coefficient: Double, plus constant: Double = 0) -> UnitConverterLinear {
        UnitConverterLinear(coefficient: coefficient, constant: constant)
    }

    static let entries: [UnitEntry] = [
        UnitEntry(["mg", "milligram", "milligrams"], UnitMass.milligrams, "mg", "Milligrams", to: "g"),
        UnitEntry(["g", "gram", "grams"], UnitMass.grams, "g", "Grams", to: "oz"),
        UnitEntry(["kg", "kilo", "kilos", "kilogram", "kilograms"], UnitMass.kilograms, "kg", "Kilograms", to: "lb"),
        UnitEntry(["t", "tonne", "tonnes"], UnitMass.metricTons, "t", "Tonnes", to: "kg"),
        UnitEntry(["oz", "ounce", "ounces"], UnitMass(symbol: "oz", converter: exactly(0.028349523125)), "oz", "Ounces", to: "g"),
        UnitEntry(["lb", "lbs", "pound", "pounds"], UnitMass(symbol: "lb", converter: exactly(0.45359237)), "lb", "Pounds", to: "kg"),
        UnitEntry(["st", "stone", "stones"], UnitMass(symbol: "st", converter: exactly(6.35029318)), "st", "Stone", to: "kg"),

        UnitEntry(["mm", "millimeter", "millimeters", "millimetre", "millimetres"], UnitLength.millimeters, "mm", "Millimetres", to: "in"),
        UnitEntry(["cm", "centimeter", "centimeters", "centimetre", "centimetres"], UnitLength.centimeters, "cm", "Centimetres", to: "in"),
        UnitEntry(["m", "meter", "meters", "metre", "metres"], UnitLength.meters, "m", "Metres", to: "ft"),
        UnitEntry(["km", "kilometer", "kilometers", "kilometre", "kilometres"], UnitLength.kilometers, "km", "Kilometres", to: "mi"),
        UnitEntry(["in", "inch", "inches"], UnitLength.inches, "in", "Inches", to: "cm"),
        UnitEntry(["ft", "foot", "feet"], UnitLength.feet, "ft", "Feet", to: "m"),
        UnitEntry(["yd", "yard", "yards"], UnitLength.yards, "yd", "Yards", to: "m"),
        UnitEntry(["mi", "mile", "miles"], UnitLength.miles, "mi", "Miles", to: "km"),

        UnitEntry(["c", "°c", "celsius", "degrees celsius"], UnitTemperature.celsius, "°C", "Celsius", to: "f"),
        UnitEntry(["f", "°f", "fahrenheit", "degrees fahrenheit"], UnitTemperature(symbol: "°F", converter: exactly(kelvinPerFahrenheit, plus: fahrenheitAtAbsoluteZero * kelvinPerFahrenheit)), "°F", "Fahrenheit", to: "c"),
        UnitEntry(["k", "kelvin"], UnitTemperature.kelvin, "K", "Kelvin", to: "c"),

        UnitEntry(["ml", "milliliter", "milliliters", "millilitre", "millilitres"], UnitVolume.milliliters, "mL", "Millilitres", to: "fl oz"),
        UnitEntry(["l", "liter", "liters", "litre", "litres"], UnitVolume.liters, "L", "Litres", to: "gal"),
        UnitEntry(["tsp", "teaspoon", "teaspoons"], UnitVolume(symbol: "tsp", converter: exactly(0.00492892159375)), "tsp", "Teaspoons", to: "ml"),
        UnitEntry(["tbsp", "tablespoon", "tablespoons"], UnitVolume(symbol: "tbsp", converter: exactly(0.01478676478125)), "tbsp", "Tablespoons", to: "ml"),
        UnitEntry(["cup", "cups"], UnitVolume(symbol: "cup", converter: exactly(0.2365882365)), "cups", "Cups", to: "ml"),
        UnitEntry(["fl oz", "fluid ounce", "fluid ounces"], UnitVolume(symbol: "fl oz", converter: exactly(0.0295735295625)), "fl oz", "Fluid Ounces", to: "ml"),
        UnitEntry(["pt", "pint", "pints"], UnitVolume(symbol: "pt", converter: exactly(0.473176473)), "pt", "Pints", to: "l"),
        UnitEntry(["gal", "gallon", "gallons"], UnitVolume(symbol: "gal", converter: exactly(3.785411784)), "gal", "Gallons", to: "l"),

        UnitEntry(["km/h", "kmh", "kph"], UnitSpeed(symbol: "km/h", converter: exactly(1 / 3.6)), "km/h", "Kilometres per Hour", to: "mph"),
        UnitEntry(["mph"], UnitSpeed.milesPerHour, "mph", "Miles per Hour", to: "km/h"),
        UnitEntry(["m/s"], UnitSpeed.metersPerSecond, "m/s", "Metres per Second", to: "km/h"),
        UnitEntry(["kn", "knot", "knots"], UnitSpeed(symbol: "kn", converter: exactly(1852.0 / 3600.0)), "kn", "Knots", to: "km/h"),

        UnitEntry(["s", "sec", "secs", "second", "seconds"], UnitDuration.seconds, one: "second", other: "seconds", "Seconds", to: "min"),
        UnitEntry(["min", "mins", "minute", "minutes"], UnitDuration.minutes, one: "minute", other: "minutes", "Minutes", to: "h"),
        UnitEntry(["h", "hr", "hrs", "hour", "hours"], UnitDuration.hours, one: "hour", other: "hours", "Hours", to: "min"),
        UnitEntry(["d", "day", "days"], duration("d", days: 1), one: "day", other: "days", "Days", to: "wk"),
        UnitEntry(["wk", "wks", "week", "weeks"], duration("wk", days: 7), one: "week", other: "weeks", "Weeks", to: "d"),
        UnitEntry(["mo", "month", "months"], duration("mo", days: daysPerMonth), one: "month", other: "months", "Months", to: "d"),
        UnitEntry(["yr", "yrs", "year", "years"], duration("yr", days: daysPerYear), one: "year", other: "years", "Years", to: "d"),

        UnitEntry(["kb", "kilobyte", "kilobytes"], UnitInformationStorage.kilobytes, "KB", "Kilobytes", to: "mb"),
        UnitEntry(["mb", "megabyte", "megabytes"], UnitInformationStorage.megabytes, "MB", "Megabytes", to: "gb"),
        UnitEntry(["gb", "gigabyte", "gigabytes"], UnitInformationStorage.gigabytes, "GB", "Gigabytes", to: "mb"),
        UnitEntry(["tb", "terabyte", "terabytes"], UnitInformationStorage.terabytes, "TB", "Terabytes", to: "gb"),

        UnitEntry(["sq m", "m2", "square meters", "square metres"], UnitArea.squareMeters, "m²", "Square Metres", to: "sq ft"),
        UnitEntry(["sq km", "km2", "square kilometers", "square kilometres"], UnitArea.squareKilometers, "km²", "Square Kilometres", to: "sq mi"),
        UnitEntry(["sq ft", "ft2", "square feet"], UnitArea.squareFeet, "ft²", "Square Feet", to: "sq m"),
        UnitEntry(["sq mi", "mi2", "square miles"], UnitArea.squareMiles, "mi²", "Square Miles", to: "sq km"),
        UnitEntry(["acre", "acres"], UnitArea.acres, "ac", "Acres", to: "ha"),
        UnitEntry(["ha", "hectare", "hectares"], UnitArea.hectares, "ha", "Hectares", to: "acres"),

        UnitEntry(["kcal", "calories", "kilocalories"], UnitEnergy.kilocalories, "kcal", "Kilocalories", to: "kj"),
        UnitEntry(["kj", "kilojoules"], UnitEnergy.kilojoules, "kJ", "Kilojoules", to: "kcal"),
    ]

    private static let byName = Dictionary(entries.flatMap { entry in entry.names.map { ($0, entry) } }) { first, _ in first }

    static func entry(named name: String) -> UnitEntry? {
        byName[name]
    }
}
