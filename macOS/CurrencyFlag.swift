import SwiftUI

/// A currency's flag, made from the first two letters of its code, because they name its country or region. The euro's EU makes the European flag.
struct CurrencyFlag: View {
    private static let regionalIndicatorOffset: UInt32 = 0x1F1E6 - 0x41
    private static let regionCodeLength = 2

    let code: String

    var body: some View {
        Text(flag)
            .font(.system(size: 17))
    }

    private var flag: String {
        let scalars = code.prefix(Self.regionCodeLength).unicodeScalars.compactMap { Unicode.Scalar($0.value + Self.regionalIndicatorOffset) }
        return String(String.UnicodeScalarView(scalars))
    }
}
