import SwiftUI

/// Celebration animation when user unlocks a badge
struct BadgeUnlockView: View {
    let badge: UnlockedBadge
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = -10

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Top sparkles
                HStack(spacing: 16) {
                    Text("✨")
                        .font(.system(size: 28))
                        .scaleEffect(scale)

                    Text("✨")
                        .font(.system(size: 32))
                        .scaleEffect(scale)

                    Text("✨")
                        .font(.system(size: 28))
                        .scaleEffect(scale)
                }

                // Badge emoji - large and animated
                Text(badge.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .animation(
                        Animation.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.3)
                            .delay(0.1),
                        value: scale
                    )

                // Badge text
                VStack(spacing: 8) {
                    Text("BADGE UNLOCKED!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.emerald)
                        .tracking(1)

                    Text(badge.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(badge.badgeDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(scale)
                .animation(
                    Animation.spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.3)
                        .delay(0.15),
                    value: scale
                )
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
                    .stroke(AppColors.teal.opacity(0.5), lineWidth: 2)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            scale = 1.0
            rotation = 0

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
    BadgeUnlockView(badge: UnlockedBadge(badgeType: .masterGardener))
}
