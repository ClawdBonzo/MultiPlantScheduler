import SwiftUI

/// Semantic color and design system for MultiPlant Scheduler
/// Provides centralized, consistent theming across the app
struct AppTheme {
    // MARK: - Color Palette

    enum Surface {
        static let primary = Color(red: 0.059, green: 0.063, blue: 0.063)      // Deep dark background
        static let secondary = Color(red: 0.12, green: 0.127, blue: 0.127)     // Slightly lighter surface
        static let tertiary = Color(red: 0.18, green: 0.188, blue: 0.188)      // Card background
        static let quaternary = Color(red: 0.25, green: 0.258, blue: 0.258)    // Hover state
    }

    enum Text {
        static let primary = Color(red: 0.95, green: 0.96, blue: 0.96)         // Almost white
        static let secondary = Color(red: 0.55, green: 0.58, blue: 0.60)       // Muted gray
        static let tertiary = Color(red: 0.35, green: 0.38, blue: 0.40)        // Dimmer text
    }

    enum Brand {
        static let primary = Color(red: 0.196, green: 0.804, blue: 0.196)      // Lime green
        static let secondary = Color(red: 0.133, green: 0.545, blue: 0.133)    // Forest green
        static let accent = Color(red: 0.15, green: 0.78, blue: 0.42)          // Emerald
    }

    enum Semantic {
        static let success = Color(red: 0.15, green: 0.78, blue: 0.42)         // Emerald
        static let warning = Color(red: 1.0, green: 0.82, blue: 0.28)          // Gold
        static let critical = Color(red: 1.0, green: 0.32, blue: 0.32)         // Red
        static let info = Color(red: 0.4, green: 0.84, blue: 0.97)             // Sky blue
    }

    enum Gradients {
        static let premium = LinearGradient(
            colors: [
                Color(red: 0.196, green: 0.804, blue: 0.196),
                Color(red: 0.15, green: 0.78, blue: 0.42)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let levelUp = LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.82, blue: 0.28),
                Color(red: 1.0, green: 0.6, blue: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let streak = LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.6, blue: 0.2),
                Color(red: 1.0, green: 0.3, blue: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Typography

    enum Typography {
        static let title1 = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 24, weight: .bold, design: .rounded)

        static let headline = Font.system(size: 20, weight: .semibold, design: .default)
        static let subheadline = Font.system(size: 16, weight: .semibold, design: .default)

        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)

        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)

        static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let button = Font.system(size: 16, weight: .semibold, design: .rounded)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius

    enum Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let full: CGFloat = .infinity
    }

    // MARK: - Shadow

    static let shadowSmall = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    static let shadowMedium = Shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    static let shadowLarge = Shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat

        func apply(to view: some View) -> some View {
            view.shadow(color: color, radius: radius, x: x, y: y)
        }
    }
}

// MARK: - Convenience Aliases

typealias AppSurface = AppTheme.Surface
typealias AppText = AppTheme.Text
typealias AppBrand = AppTheme.Brand
typealias AppSemantic = AppTheme.Semantic
