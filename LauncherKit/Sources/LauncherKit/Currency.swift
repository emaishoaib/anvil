import Foundation

/// A currency the currency table can list, by its ISO code and its name in the Mac's language.
public struct Currency: Hashable, Sendable, Identifiable {
    public let code: String
    public let name: String

    public var id: String {
        code
    }

    public init(code: String, locale: Locale = .current) {
        self.code = code
        name = Measure.currency(code).label(locale: locale)
    }
}
