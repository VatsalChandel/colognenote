import SwiftUI
import UIKit

/// Design tokens. One place for spacing, corner radii, and semantic colors so screens
/// stay visually consistent. Typography uses the system text styles (Dynamic Type)
/// with a serif accent for display headings.
enum Theme {

    enum Spacing {
        /// 4
        static let xs: CGFloat = 4
        /// 8
        static let sm: CGFloat = 8
        /// 12
        static let md: CGFloat = 12
        /// 16
        static let lg: CGFloat = 16
        /// 24
        static let xl: CGFloat = 24
        /// 32
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
    }

    enum Palette {
        static let accent = Color.accentColor
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let groupedBackground = Color(uiColor: .systemGroupedBackground)
        static let cardBackground = Color(uiColor: .secondarySystemBackground)
        static let primaryText = Color(uiColor: .label)
        static let secondaryText = Color(uiColor: .secondaryLabel)
        static let tertiaryText = Color(uiColor: .tertiaryLabel)
        static let separator = Color(uiColor: .separator)
        static let destructive = Color.red
        /// Rating indicator.
        static let rating = Color.orange
    }

    enum Typography {
        /// Serif display font for large titles / hero copy.
        static func display(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .serif)
        }
    }
}

extension View {
    /// Standard screen padding.
    func screenPadding() -> some View {
        padding(.horizontal, Theme.Spacing.lg)
    }
}
