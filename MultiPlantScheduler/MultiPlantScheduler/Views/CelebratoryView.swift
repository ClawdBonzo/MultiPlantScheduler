import SwiftUI

/// Full-screen celebration shown after saving the first plant from onboarding
struct CelebratoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    @State private var leafOffsets: [(x: CGFloat, y: CGFloat, rotation: Double, delay: Double)] = []

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Animated falling leaves
            ForEach(0..<12, id: \.self) { index in
                if index < leafOffsets.count {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: CGFloat.random(in: 16...28)))
                        .foregroundStyle(AppColors.limeGreen.opacity(Double.random(in: 0.3...0.7)))
                        .offset(
                            x: leafOffsets[index].x,
                            y: showContent ? leafOffsets[index].y : -100
                        )
                        .rotationEffect(.degrees(showContent ? leafOffsets[index].rotation : 0))
                        .animation(
                            .easeOut(duration: 1.5).delay(leafOffsets[index].delay),
                            value: showContent
                        )
                }
            }

            // Main content
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(AppColors.limeGreen)
                    .scaleEffect(showContent ? 1 : 0.3)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)

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
            // Generate random leaf positions
            leafOffsets = (0..<12).map { _ in
                (
                    x: CGFloat.random(in: -160...160),
                    y: CGFloat.random(in: 100...600),
                    rotation: Double.random(in: -180...180),
                    delay: Double.random(in: 0...0.8)
                )
            }

            withAnimation {
                showContent = true
            }

            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                dismiss()
            }
        }
    }
}

#Preview {
    CelebratoryView()
}
