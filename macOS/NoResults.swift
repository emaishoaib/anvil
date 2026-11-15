import SwiftUI

/// Stands in for a list that has nothing to show, so the search bar says that nothing matched instead of showing a blank space.
struct NoResults: View {
    var body: some View {
        Text("No Results")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
