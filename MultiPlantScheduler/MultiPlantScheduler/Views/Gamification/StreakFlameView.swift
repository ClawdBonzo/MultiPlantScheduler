import SwiftUI

/// Visual indicator for streak milestones with flame animation
struct StreakFlameView: View {
    let currentStreak: Int
    let multiplier: Float
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    @State private var flameRotation: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Flame emoji with rotation
                Text("🔥")
                    .font(.system(size: 64))
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(flameRotation))
                    .animation(
                        Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.3),
                        value: scale
                    )
                    .onAppear {
                        scale = 1.0
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                            flameRotation = 5
                        }
                    }

                // Streak milestone text
                VStack(spacing: 8) {
                    Text("STREAK MILESTONE!")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                        .tracking(1)

                    Text("\(currentStreak) Day Streak")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 12) {
                        Text("Multiplier")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("×\(String(format: "%.1f", multiplier))")
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.emerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                .scaleEffect(scale)
                .animation(
                    Animation.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.3)
                        .delay(0.1),
                    value: scale
                )

                // Keep it going message
                Text("Keep it up!")
                    .font(.caption)
                    .foregroundColor(AppColors.teal)
                    .opacity(scale > 0.8 ? 1 : 0)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.9),
                                Color.black.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange.opacity(0.4), lineWidth: 2)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    opacity = 0
                    scale = 0.8
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StreakFlameView(currentStreak: 7, multiplier: 1.2)
}
