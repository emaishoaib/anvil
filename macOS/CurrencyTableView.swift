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
    let row: CurrencyTable.Row

    var body: some View {
        HStack(spacing: 10) {
            CurrencyFlag(code: row.code)
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
}
