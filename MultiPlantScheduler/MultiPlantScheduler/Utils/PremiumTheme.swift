import SwiftUI

// MARK: - Premium Color Palette

extension Constants.Colors {
    // Richer emerald/teal spectrum
    static let emerald = Color(red: 0.05, green: 0.65, blue: 0.42)
    static let teal = Color(red: 0.08, green: 0.55, blue: 0.52)
    static let jade = Color(red: 0.10, green: 0.74, blue: 0.45)
    static let mint = Color(red: 0.30, green: 0.87, blue: 0.62)
    static let deepForest = Color(red: 0.04, green: 0.18, blue: 0.08)

    // Surface colors for layered dark UI
    static let surface0 = Color(red: 0.071, green: 0.071, blue: 0.071) // base
    static let surface1 = Color(red: 0.098, green: 0.098, blue: 0.098) // elevated
    static let surface2 = Color(red: 0.118, green: 0.118, blue: 0.118) // card
    static let surface3 = Color(red: 0.145, green: 0.145, blue: 0.145) // modal

    // Accent glow
    static let limeGlow = limeGreen.opacity(0.35)
    static let emeraldGlow = emerald.opacity(0.30)
}

// MARK: - Premium Gradients

enum PremiumGradient {
    /// Primary brand gradient — emerald to lime
    static let brand = LinearGradient(
        colors: [AppColors.emerald, AppColors.limeGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle card gradient stroke
    static func cardStroke(opacity: Double = 0.15) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(opacity),
                AppColors.limeGreen.opacity(opacity * 0.6),
                Color.white.opacity(opacity * 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Hero gradient for section headers
    static let hero = LinearGradient(
        colors: [
            AppColors.deepForest,
            AppColors.emerald.opacity(0.4),
            AppColors.limeGreen.opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Button gradient — rich and saturated
    static let button = LinearGradient(
        colors: [AppColors.emerald, AppColors.limeGreen, AppColors.jade],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Paywall hero gradient
    static let paywallHero = LinearGradient(
        colors: [
            Color(red: 0.02, green: 0.15, blue: 0.06),
            Color(red: 0.05, green: 0.35, blue: 0.15),
            Color(red: 0.08, green: 0.55, blue: 0.25),
            Color(red: 0.15, green: 0.70, blue: 0.35)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Tab bar background
    static let tabBar = LinearGradient(
        colors: [
            Color(red: 0.055, green: 0.055, blue: 0.055),
            Color(red: 0.065, green: 0.065, blue: 0.065)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Spring Animation Presets

enum SpringPreset {
    /// Snappy micro-interactions (button taps, toggles)
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.7)

    /// Bouncy feedback (vote buttons, scale effects)
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.55)

    /// Smooth page transitions
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.82)

    /// Dramatic entrances
    static let dramatic = Animation.spring(response: 0.65, dampingFraction: 0.68)

    /// Gentle float (cards, parallax)
    static let gentle = Animation.spring(response: 0.8, dampingFraction: 0.75)
}

// MARK: - Premium Glass Card Modifier

struct PremiumGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    var strokeOpacity: Double = 0.12
    var innerShadowOpacity: Double = 0.06
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        .ultraThinMaterial
                            .shadow(.inner(color: .white.opacity(innerShadowOpacity), radius: 1, x: 0, y: 1))
                            .shadow(.inner(color: .black.opacity(0.2), radius: 2, x: 0, y: -1))
                    )
                    .environment(\.colorScheme, .dark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        PremiumGradient.cardStroke(opacity: strokeOpacity),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

extension View {
    /// Apply premium glassmorphism card styling
    func premiumGlass(
        cornerRadius: CGFloat = 16,
        strokeOpacity: Double = 0.12,
        padding: CGFloat = 16
    ) -> some View {
        modifier(PremiumGlassCard(
            cornerRadius: cornerRadius,
            strokeOpacity: strokeOpacity,
            padding: padding
        ))
    }
}

// MARK: - Glow Button Modifier

struct GlowButtonStyle: ViewModifier {
    var glowColor: Color = AppColors.limeGreen
    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(PremiumGradient.button)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: glowColor.opacity(0.4), radius: 12, x: 0, y: 6)
            .shadow(color: glowColor.opacity(0.15), radius: 24, x: 0, y: 12)
    }
}

extension View {
    func premiumButton(glowColor: Color = AppColors.limeGreen, cornerRadius: CGFloat = 14) -> some View {
        modifier(GlowButtonStyle(glowColor: glowColor, cornerRadius: cornerRadius))
    }
}

// MARK: - Animated Entrance Modifier

struct AnimatedEntrance: ViewModifier {
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .scaleEffect(appeared ? 1 : 0.97)
            .animation(
                SpringPreset.smooth.delay(delay),
                value: appeared
            )
            .onAppear {
                appeared = true
            }
    }
}

extension View {
    func animatedEntrance(delay: Double = 0) -> some View {
        modifier(AnimatedEntrance(delay: delay))
    }
}

// MARK: - Premium Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.12),
                        Color.white.opacity(0.05),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        phase = 400
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func premiumShimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Particle Glow View

/// Subtle floating glow particles for premium backgrounds
struct ParticleGlowView: View {
    let particleCount: Int
    let color: Color

    init(count: Int = 8, color: Color = AppColors.limeGreen) {
        self.particleCount = count
        self.color = color
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<particleCount, id: \.self) { i in
                GlowParticle(
                    index: i,
                    bounds: geo.size,
                    color: color
                )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct GlowParticle: View {
    let index: Int
    let bounds: CGSize
    let color: Color
    @State private var offset: CGPoint = .zero
    @State private var opacity: Double = 0

    private var size: CGFloat {
        CGFloat([20, 30, 15, 25, 18, 35, 22, 28][index % 8])
    }

    private var initialX: CGFloat {
        CGFloat([0.1, 0.3, 0.5, 0.7, 0.9, 0.2, 0.6, 0.8][index % 8]) * bounds.width
    }

    private var initialY: CGFloat {
        CGFloat([0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.1, 0.4][index % 8]) * bounds.height
    }

    var body: some View {
        Circle()
            .fill(color.opacity(0.25))
            .blur(radius: size * 0.6)
            .frame(width: size, height: size)
            .position(x: initialX + offset.x, y: initialY + offset.y)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true)) {
                    offset = CGPoint(
                        x: CGFloat.random(in: -30...30),
                        y: CGFloat.random(in: -30...30)
                    )
                    opacity = Double.random(in: 0.3...0.7)
                }
            }
    }
}

// MARK: - Success Burst Effect

/// Quick radial burst for scan complete / diagnosis success moments
struct SuccessBurstView: View {
    @Binding var trigger: Bool
    var color: Color = AppColors.limeGreen

    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0.8
    @State private var ring2Scale: CGFloat = 0.2
    @State private var ring2Opacity: Double = 0.6

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(ringOpacity), lineWidth: 3)
                .scaleEffect(ringScale)

            Circle()
                .stroke(color.opacity(ring2Opacity), lineWidth: 2)
                .scaleEffect(ring2Scale)
        }
        .onChange(of: trigger) { _, newValue in
            if newValue {
                ringScale = 0.3
                ringOpacity = 0.8
                ring2Scale = 0.2
                ring2Opacity = 0.6

                withAnimation(.easeOut(duration: 0.7)) {
                    ringScale = 2.0
                    ringOpacity = 0
                }
                withAnimation(.easeOut(duration: 0.9).delay(0.1)) {
                    ring2Scale = 2.5
                    ring2Opacity = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    trigger = false
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Premium Section Header

struct PremiumSectionHeader: View {
    let icon: String
    let iconColor: Color
    let title: String
    var trailing: String? = nil
    var trailingColor: Color = AppColors.limeGreen

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [iconColor, iconColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(trailingColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(trailingColor.opacity(0.12))
                    .cornerRadius(6)
            }
        }
    }
}
