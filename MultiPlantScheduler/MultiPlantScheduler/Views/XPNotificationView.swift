import SwiftUI

/// Floating XP notification that appears when user earns XP
struct XPNotificationView: View {
    let amount: Int
    let source: String
    @State private var isAnimating = false
    @State private var opacity = 1.0

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)

                Text("+\(amount) XP")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)

                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(AppBrand.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppSurface.secondary.opacity(0.9),
                        AppSurface.tertiary.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppBrand.primary.opacity(0.3), lineWidth: 1)
            )

            Text(source)
                .font(.caption)
                .foregroundColor(AppText.secondary)
        }
        .offset(y: isAnimating ? -80 : 0)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.4)) {
                    opacity = 0
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppSurface.primary.ignoresSafeArea()

        VStack {
            XPNotificationView(amount: 50, source: "Quest Completed")
            Spacer()
        }
        .padding(24)
    }
}
