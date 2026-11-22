import LauncherKit
import SwiftUI

/// The query's money in the top currencies, shown under the answer and before the other results. Each row has the currency's flag, code and name with the amount at the end. The rows are only there to read, so moving through the results passes them by.
struct CurrencyTableView: View {
    private static let rowHeight: CGFloat = 32

    let table: CurrencyTable

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Currencies")
            ForEach(table.rows) { row in
                CurrencyRow(row: row)
                    .frame(height: Self.rowHeight)
            }
        }
    }
}

private struct CurrencyRow: View {
    private static let regionalIndicatorOffset: UInt32 = 0x1F1E6 - 0x41
    private static let regionCodeLength = 2

    let row: CurrencyTable.Row

    var body: some View {
        HStack(spacing: 10) {
            Text(flag)
                .font(.system(size: 17))
            Text(row.code)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(row.name)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
            Text(row.amount)
                .monospacedDigit()
                .foregroundStyle(Color(nsColor: .textColor))
        }
        .padding(.horizontal, 8)
    }

    private var flag: String {
        let scalars = row.code.prefix(Self.regionCodeLength).unicodeScalars.compactMap { Unicode.Scalar($0.value + Self.regionalIndicatorOffset) }
        return String(String.UnicodeScalarView(scalars))
    }
}
