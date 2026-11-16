import SwiftUI

/// A table from Claude's answer, with its header in bold and a line under it. A row with fewer cells than the header leaves the rest blank.
struct AnswerTable: View {
    let header: [AttributedString]
    let rows: [[AttributedString]]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
            GridRow {
                ForEach(header.indices, id: \.self) { column in
                    Text(header[column])
                        .fontWeight(.semibold)
                }
            }
            Divider()
            ForEach(rows.indices, id: \.self) { row in
                GridRow {
                    ForEach(header.indices, id: \.self) { column in
                        Text(rows[row].indices.contains(column) ? rows[row][column] : "")
                    }
                }
            }
        }
    }
}
