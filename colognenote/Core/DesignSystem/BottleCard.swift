import SwiftUI

/// The unit of the collection grid: bottle photo, name, house, and a small rating row.
/// Takes primitives so it's reusable for search results and previews, not just owned items.
struct BottleCard: View {
    var name: String
    var house: String?
    var imageURL: String?
    var rating: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            RemoteImage(urlString: imageURL)
                .frame(maxWidth: .infinity)
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                if let house, !house.isEmpty {
                    Text(house)
                        .font(.caption)
                        .foregroundStyle(Theme.Palette.secondaryText)
                        .lineLimit(1)
                }
            }

            if rating != nil {
                RatingView(rating: rating)
            }
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Palette.cardBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.lg))
    }
}

extension BottleCard {
    /// Convenience for an owned item row.
    init(item: CollectionItemRow) {
        self.init(
            name: item.fragrance.name,
            house: item.fragrance.house,
            imageURL: item.photoUrl ?? item.fragrance.imageUrl,
            rating: item.personalRating
        )
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.lg) {
            BottleCard(name: "Sauvage", house: "Dior", imageURL: nil, rating: 4)
            BottleCard(name: "Bleu de Chanel", house: "Chanel", imageURL: nil, rating: 5)
            BottleCard(name: "Aventus", house: "Creed", imageURL: nil, rating: nil)
        }
        .padding()
    }
}
