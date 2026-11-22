import LauncherKit
import SwiftUI

/// The query's money in the chosen currencies, shown under the answer and before the other results. Each row has the currency's flag, code and name with the amount at the end. The rows are only there to read, so moving through the results passes them by, and the pencil across from the title opens the page for choosing the currencies.
struct CurrencyTableView: View {
    private static let rowHeight: CGFloat = 32

    let table: CurrencyTable
    let edit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionHeader(title: "Currencies")
                Spacer()
                EditButton(action: edit)
            }
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

private struct EditButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "pencil")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(6)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help("Choose Currencies")
    }
}
