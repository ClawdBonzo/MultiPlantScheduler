import SwiftUI

/// Full-screen celebration shown after saving the first plant from onboarding
struct CelebratoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    @State private var checkScale: CGFloat = 0.05
    @State private var checkRotation: Double = -90
    @State private var ring1Scale: CGFloat = 0.3
    @State private var ring2Scale: CGFloat = 0.3
    @State private var ring3Scale: CGFloat = 0.3
    @State private var ringOpacity: Double = 1.0
    @State private var glowPulse = false
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var confettiLaunched = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Flash overlay
            Color.white.opacity(showContent ? 0 : 0.15)
                .ignoresSafeArea()
                .animation(.easeOut(duration: 0.4), value: showContent)

            // Confetti particles — 50 total
            GeometryReader { geo in
                ForEach(confettiParticles) { particle in
                    Image(systemName: particle.icon)
                        .font(.system(size: particle.size))
                        .foregroundStyle(particle.color.opacity(confettiLaunched ? 0 : particle.opacity))
                        .position(
                            x: confettiLaunched
                                ? particle.endX * geo.size.width
                                : geo.size.width / 2,
                            y: confettiLaunched
                                ? particle.endY * geo.size.height
                                : geo.size.height * 0.40
                        )
                        .rotationEffect(.degrees(confettiLaunched ? particle.rotation : 0))
                        .scaleEffect(confettiLaunched ? 0.3 : 1.0)
                        .animation(
                            .easeOut(duration: particle.duration).delay(particle.delay),
                            value: confettiLaunched
                        )
                }
            }
            .ignoresSafeArea()

            // Main content
            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    // Pulsing glow background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.limeGreen.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(glowPulse ? 1.2 : 0.8)
                        .opacity(glowPulse ? 0.6 : 1.0)

                    // Ring 3 (outermost)
                    Circle()
                        .stroke(AppColors.limeGreen.opacity(ringOpacity * 0.1), lineWidth: 1.5)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ring3Scale)

                    // Ring 2
                    Circle()
                        .stroke(AppColors.limeGreen.opacity(ringOpacity * 0.2), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ring2Scale)

                    // Ring 1 (closest)
                    Circle()
                        .stroke(AppColors.limeGreen.opacity(ringOpacity * 0.35), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ring1Scale)

                    // Checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 90, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.limeGreen, AppColors.forestGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(checkScale)
                        .rotationEffect(.degrees(checkRotation))
                        .shadow(color: AppColors.limeGreen.opacity(0.6), radius: 30)
                }

                VStack(spacing: 10) {
                    Text("Your First Plant is Saved!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    Text("Your garden has begun")
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .scaleEffect(showContent ? 1 : 0.8)

                Spacer()
            }
        }
        .onAppear {
            generateConfetti()

            // Strong haptic
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)

            // Checkmark: dramatic spring with rotation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.45)) {
                checkScale = 1.15
                checkRotation = 10
            }
            // Settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    checkScale = 1.0
                    checkRotation = 0
                }
            }

            // Expanding rings — staggered
            withAnimation(.easeOut(duration: 1.2)) {
                ring1Scale = 2.0
            }
            withAnimation(.easeOut(duration: 1.4).delay(0.1)) {
                ring2Scale = 3.0
            }
            withAnimation(.easeOut(duration: 1.6).delay(0.2)) {
                ring3Scale = 4.0
            }
            withAnimation(.easeOut(duration: 1.5)) {
                ringOpacity = 0
            }

            // Glow pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowPulse = true
            }

            // Confetti burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    confettiLaunched = true
                }
                // Second haptic on confetti
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
            }

            // Text appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    showContent = true
                }
            }

            // Auto-dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        }
    }

    private func generateConfetti() {
        let icons = ["leaf.fill", "sparkle", "star.fill", "drop.fill", "heart.fill", "leaf.fill"]
        let colors: [Color] = [AppColors.limeGreen, .green, .yellow, .cyan, .mint, .white, AppColors.limeGreen]

        confettiParticles = (0..<50).map { _ in
            ConfettiParticle(
                endX: CGFloat.random(in: -0.1...1.1),
                endY: CGFloat.random(in: 0.05...0.95),
                size: CGFloat.random(in: 14...28),
                opacity: Double.random(in: 0.5...1.0),
                rotation: Double.random(in: -540...540),
                duration: Double.random(in: 0.9...1.8),
                delay: Double.random(in: 0...0.25),
                icon: icons.randomElement()!,
                color: colors.randomElement()!
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let endX: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let opacity: Double
    let rotation: Double
    let duration: Double
    let delay: Double
    let icon: String
    let color: Color
}

#Preview {
    CelebratoryView()
}
