import SwiftUI

/// Celebratory full-screen overlay for streak milestones — premium particle effects
struct StreakMilestoneView: View {
    let days: Int
    @Environment(\.dismiss) var dismiss
    @State private var animateFlame = false
    @State private var animateScale = false
    @State private var animateConfetti = false
    @State private var showContent = false
    @State private var burstTrigger = false

    private var milestoneEmoji: String {
        switch days {
        case 3: return "🌱"
        case 7: return "🌿"
        case 14: return "🌳"
        case 21: return "🌲"
        case 30: return "🏆"
        case 60: return "💎"
        case 90: return "👑"
        case 180: return "🌟"
        case 365: return "🎉"
        default: return "🔥"
        }
    }

    private var milestoneTitle: String {
        switch days {
        case 3: return "Getting Started!"
        case 7: return "One Week Strong!"
        case 14: return "Two Weeks!"
        case 21: return "Habit Formed!"
        case 30: return "One Month Legend!"
        case 60: return "Two Month Champion!"
        case 90: return "Quarter Year Master!"
        case 180: return "Half Year Hero!"
        case 365: return "Plant Parent of the Year!"
        default: return "\(days) Day Streak!"
        }
    }

    var body: some View {
        ZStack {
            // Deep background
            Color(red: 0.03, green: 0.03, blue: 0.03).ignoresSafeArea()

            // Animated radial glow
            RadialGradient(
                colors: [.orange.opacity(0.15), AppColors.emerald.opacity(0.05), .clear],
                center: .center,
                startRadius: 10,
                endRadius: animateFlame ? 450 : 200
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateFlame)

            // Ambient particles
            ParticleGlowView(count: 8, color: .orange)
                .opacity(0.6)
                .ignoresSafeArea()

            // Confetti particles
            if animateConfetti {
                ForEach(0..<24, id: \.self) { i in
                    StreakConfettiDot(index: i)
                }
            }

            // Success burst rings
            SuccessBurstView(trigger: $burstTrigger, color: .orange)
                .frame(width: 200, height: 200)

            // Content
            VStack(spacing: 28) {
                Spacer()

                // Emoji — dramatic scale-in
                Text(milestoneEmoji)
                    .font(.system(size: 80))
                    .scaleEffect(animateScale ? 1.0 : 0.2)
                    .animation(.spring(response: 0.7, dampingFraction: 0.45).delay(0.2), value: animateScale)

                // Streak details
                if showContent {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                            Text("\(days)")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("days")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Text(milestoneTitle)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Your plants thank you for being consistent!")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                // Dismiss CTA
                if showContent {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        dismiss()
                    } label: {
                        Text("Keep Growing!")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .yellow, .orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: .orange.opacity(0.4), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 44)
                    .transition(.opacity.combined(with: .offset(y: 20)))
                }
            }
        }
        .onAppear {
            animateFlame = true
            animateScale = true
            animateConfetti = true

            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                burstTrigger = true
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                showContent = true
            }
        }
    }
}

// MARK: - Confetti Particle

struct StreakConfettiDot: View {
    let index: Int
    @State private var animate = false

    private var randomColor: Color {
        [Color.orange, .yellow, .red, AppColors.emerald, .blue, .purple, .pink, .cyan][index % 8]
    }

    private var randomX: CGFloat {
        CGFloat.random(in: -180...180)
    }

    private var randomDelay: Double {
        Double.random(in: 0...0.8)
    }

    var body: some View {
        Circle()
            .fill(randomColor)
            .frame(width: CGFloat.random(in: 4...10), height: CGFloat.random(in: 4...10))
            .offset(
                x: animate ? randomX : 0,
                y: animate ? CGFloat.random(in: 200...500) : -100
            )
            .opacity(animate ? 0 : 1)
            .animation(
                .easeOut(duration: Double.random(in: 1.5...3.0))
                    .delay(randomDelay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}
