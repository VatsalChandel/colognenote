import SwiftUI

/// A faded, non-interactive grid of placeholder bottles. Sits behind the empty
/// state so a new user sees where they're headed (screen spec #1).
struct SampleShelfBackdrop: View {
    private let samples: [(String, String)] = [
        ("Sauvage", "Dior"), ("Bleu de Chanel", "Chanel"),
        ("Aventus", "Creed"), ("Eros", "Versace"),
        ("Layton", "Parfums de Marly"), ("Le Male", "Jean Paul Gaultier")
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.lg) {
            ForEach(samples, id: \.0) { name, house in
                BottleCard(name: name, house: house, rating: nil)
            }
        }
        .padding(Theme.Spacing.lg)
        .opacity(0.18)
        .blur(radius: 2)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    SampleShelfBackdrop()
}
