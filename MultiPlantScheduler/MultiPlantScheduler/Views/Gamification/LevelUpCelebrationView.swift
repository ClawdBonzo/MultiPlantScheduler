import SwiftUI

/// Celebration animation when user levels up
struct LevelUpCelebrationView: View {
    let level: Int
    let levelName: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    ForEach([0, 1, 2], id: \.self) { index in
                        Text("🎉")
                            .font(.system(size: 32))
                            .scaleEffect(scale)
                            .animation(
                                reduceMotion ? nil :
                                Animation.easeInOut(duration: 0.6)
                                    .delay(Double(index) * 0.1),
                                value: scale
                            )
                    }
                }

                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundColor(AppColors.emerald)
                        .tracking(2)

                    Text("Level \(level)")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)

                    Text(levelName)
                        .font(.headline)
                        .foregroundColor(AppColors.teal)
                        .textCase(.uppercase)
                        .tracking(1)
                }
                .scaleEffect(scale)
                .animation(
                    reduceMotion ? nil :
                    Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)
                        .delay(0.1),
                    value: scale
                )

                if !reduceMotion {
                    ZStack {
                        ForEach(0..<12, id: \.self) { _ in
                            LevelUpConfettiParticle()
                        }
                    }
                    .frame(height: 200)
                }
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
                    .stroke(AppColors.emerald.opacity(0.5), lineWidth: 2)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            scale = 1.0
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    opacity = 0
                    scale = 1.2
                }
            }
        }
    }
}

// MARK: - Confetti Particle

struct LevelUpConfettiParticle: View {
    @State private var position: CGFloat = 0
    @State private var rotation: Double = 0

    let emoji = ["🎉", "⭐", "🌟", "✨"].randomElement() ?? "🎉"
    let startX: CGFloat = CGFloat.random(in: -50...50)
    let startY: CGFloat = CGFloat.random(in: -50...50)
    let duration = Double.random(in: 1.5...2.5)

    var body: some View {
        Text(emoji)
            .font(.system(size: 20))
            .offset(x: startX, y: startY + position)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(1 - (position / 200))
            .onAppear {
                withAnimation(.linear(duration: duration)) {
                    position = 200
                    rotation = 360
                }
            }
    }
}

// MARK: - Preview

#Preview {
    LevelUpCelebrationView(level: 5, levelName: "Master Gardener")
}
