import SwiftUI

/// Compact 1–5 rating indicator. Read-only by default; pass `onChange` to make it tappable
/// (used in the Add / Edit form).
struct RatingView: View {
    var rating: Int?
    var size: CGFloat = 13
    var onChange: ((Int) -> Void)?

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= (rating ?? 0) ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(index <= (rating ?? 0) ? Theme.Palette.rating : Theme.Palette.tertiaryText)
                    .onTapGesture { onChange?(index) }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rating.map { "Rated \($0) out of 5" } ?? "Not rated")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        RatingView(rating: 4)
        RatingView(rating: nil)
        RatingView(rating: 3, size: 22, onChange: { _ in })
    }
    .padding()
}
