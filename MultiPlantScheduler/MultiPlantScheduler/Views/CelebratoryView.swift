import SwiftUI

/// Full-screen celebration shown after saving the first plant from onboarding
struct CelebratoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    @State private var checkScale: CGFloat = 0.1
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 1.0
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var confettiLaunched = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Confetti particles
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
                                : geo.size.height * 0.42
                        )
                        .rotationEffect(.degrees(confettiLaunched ? particle.rotation : 0))
                        .animation(
                            .easeOut(duration: particle.duration).delay(particle.delay),
                            value: confettiLaunched
                        )
                }
            }
            .ignoresSafeArea()

            // Main content
            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    // Expanding ring
                    Circle()
                        .stroke(AppColors.limeGreen.opacity(ringOpacity * 0.3), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)

                    // Second ring
                    Circle()
                        .stroke(AppColors.limeGreen.opacity(ringOpacity * 0.15), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale * 1.3)

                    // Checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.limeGreen, AppColors.forestGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(checkScale)
                        .shadow(color: AppColors.limeGreen.opacity(0.5), radius: 20)
                }

                VStack(spacing: 8) {
                    Text("Your First Plant is Saved!")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Your garden has begun")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                Spacer()
            }
        }
        .onAppear {
            generateConfetti()

            // Checkmark spring-in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                checkScale = 1.0
            }

            // Expanding ring
            withAnimation(.easeOut(duration: 1.0)) {
                ringScale = 2.5
                ringOpacity = 0
            }

            // Confetti burst
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    confettiLaunched = true
                }
            }

            // Haptic
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)

            showContent = true

            // Auto-dismiss after 1.8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                dismiss()
            }
        }
    }

    private func generateConfetti() {
        let icons = ["leaf.fill", "sparkle", "star.fill", "drop.fill", "heart.fill"]
        let colors: [Color] = [AppColors.limeGreen, .green, .yellow, .cyan, .mint, .white]

        confettiParticles = (0..<30).map { _ in
            ConfettiParticle(
                endX: CGFloat.random(in: 0.05...0.95),
                endY: CGFloat.random(in: 0.1...0.85),
                size: CGFloat.random(in: 10...22),
                opacity: Double.random(in: 0.4...0.9),
                rotation: Double.random(in: -360...360),
                duration: Double.random(in: 0.8...1.4),
                delay: Double.random(in: 0...0.3),
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
