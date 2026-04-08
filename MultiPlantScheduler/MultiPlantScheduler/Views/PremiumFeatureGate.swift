import SwiftUI

/// Component that shows premium feature badge or blocks access based on subscription status
struct PremiumFeatureGate<Content: View>: View {
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    let content: Content
    let onShowPaywall: () -> Void
    var showBadge: Bool = true

    init(
        @ViewBuilder content: () -> Content,
        showBadge: Bool = true,
        onShowPaywall: @escaping () -> Void
    ) {
        self.content = content()
        self.showBadge = showBadge
        self.onShowPaywall = onShowPaywall
    }

    var body: some View {
        if revenueCatManager.isPremium {
            ZStack(alignment: .topTrailing) {
                content

                if showBadge {
                    VStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text("PRO")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .padding(8)
                    .background(AppSurface.secondary)
                    .cornerRadius(8)
                    .padding(8)
                }
            }
        } else {
            ZStack {
                content
                    .blur(radius: 4)
                    .disabled(true)

                VStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppBrand.primary)

                    Text("Premium Only")
                        .font(.headline)
                        .foregroundColor(AppText.primary)

                    Text("Upgrade to access this feature")
                        .font(.caption)
                        .foregroundColor(AppText.secondary)

                    Button(action: onShowPaywall) {
                        Text("Upgrade")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundColor(.black)
                            .background(AppBrand.primary)
                            .cornerRadius(8)
                    }
                }
                .padding(20)
                .background(AppSurface.tertiary)
                .cornerRadius(12)
            }
        }
    }
}

/// Badge overlay for premium features
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10, weight: .bold))
            Text("PRO")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.yellow)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(4)
    }
}

#Preview {
    PremiumFeatureGate(
        content: {
            VStack {
                Text("Premium Content")
                    .font(.headline)
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
            }
            .padding(40)
            .background(AppSurface.secondary)
            .cornerRadius(12)
        },
        onShowPaywall: {}
    )
    .environmentObject(RevenueCatManager.shared)
    .padding(24)
    .background(AppSurface.primary)
}
