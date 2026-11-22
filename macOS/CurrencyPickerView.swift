import LauncherKit
import SwiftUI

/// The rows of the currency picker: the chosen currencies with nothing typed, and the currencies found once something is. Each row has the currency's flag, code and name. A chosen currency in the list has a minus that removes it, and a found currency that is already chosen has a tick. Clicking a row selects it, and an empty list says why it is empty.
struct CurrencyPickerView: View {
    private static let rowHeight: CGFloat = 36
    private static let padding: CGFloat = 8
    private static let listHeight: CGFloat = 380

    let picker: CurrencyPicker
    let query: String

    var body: some View {
        let currencies = picker.currencies(matching: query)
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: isSearching ? "Results" : "Chosen Currencies")
                    ForEach(Array(currencies.enumerated()), id: \.element.code) { index, currency in
                        CurrencyPickerRow(currency: currency, isTicked: isSearching && picker.isChosen(currency), isSelected: index == picker.selected, remove: isSearching ? nil : { picker.remove(currency, matching: query) })
                            .frame(height: Self.rowHeight)
                            .onTapGesture { picker.select(index) }
                    }
                }
                .padding(Self.padding)
            }
            .frame(height: Self.listHeight + Self.padding * 2)
            .overlay { if currencies.isEmpty { emptyMessage } }
            .onChange(of: picker.selected) {
                if let code = picker.selectedCurrency(matching: query)?.code { proxy.scrollTo(code) }
            }
        }
    }

    private var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var emptyMessage: some View {
        Text(isSearching ? "No Results" : "Type to find currencies to add")
            .foregroundStyle(.secondary)
    }
}

private struct CurrencyPickerRow: View {
    let currency: Currency
    let isTicked: Bool
    let isSelected: Bool
    let remove: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            CurrencyFlag(code: currency.code)
            Text(currency.code)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(currency.name)
                .foregroundStyle(Color(nsColor: .textColor))
                .lineLimit(1)
            Spacer()
            if isTicked {
                Image(systemName: "checkmark")
                    .foregroundStyle(.secondary)
            }
            if let remove { RemoveButton(action: remove) }
        }
        .padding(.horizontal, 8)
        .frame(maxHeight: .infinity)
        .background {
            if isSelected { RoundedRectangle(cornerRadius: SearchStyle.cornerRadius).fill(.primary.opacity(SearchStyle.selectionOpacity)) }
        }
        .contentShape(.rect)
    }
}

private struct RemoveButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "minus.circle.fill")
                .font(.system(size: 15))
                .foregroundStyle(.white, .red)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .help("Remove Currency")
    }
}
