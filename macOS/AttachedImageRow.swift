import SwiftUI

/// The image waiting to go with the next prompt, shown small just above the prompt field, with a button in its corner that takes it off.
struct AttachedImageRow: View {
    private static let height: CGFloat = 56
    private static let cornerRadius: CGFloat = 6

    let png: Data
    let remove: () -> Void

    var body: some View {
        HStack {
            if let image = NSImage(data: png) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: Self.height)
                    .clipShape(.rect(cornerRadius: Self.cornerRadius))
                    .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(.secondary.opacity(0.3)))
                    .overlay(alignment: .topTrailing) { RemoveButton(action: remove) }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
}

private struct RemoveButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .black.opacity(0.6))
        }
        .buttonStyle(.plain)
        .help("Remove Image")
        .padding(3)
    }
}
