import SwiftUI
import RevenueCat

/// Modernized paywall with 4 subscription tiers + 3-day free trial on monthly
struct ModernPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTier: String = Constants.Subscription.ProductID.monthly
    @State private var isLoading = false
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    let onComplete: (String) -> Void

    private var ctaTitle: String {
        selectedTier == Constants.Subscription.ProductID.monthly
            ? "Start 3-Day Free Trial"
            : "Continue"
    }

    private var footerText: String {
        selectedTier == Constants.Subscription.ProductID.monthly
            ? "3-day free trial, then $6.99/month. Cancel anytime."
            : "Cancel anytime in Settings."
    }

    var body: some View {
        ZStack {
            AppSurface.primary.ignoresSafeArea()

            VStack(spacing: 24) {
                // Close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppText.secondary)
                    }
                    Spacer()
                }

                // Header
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                        Text("Go Premium")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppText.primary)
                    }
                    Text("Unlimited plants, AI diagnosis & more")
                        .font(.body)
                        .foregroundColor(AppText.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView {
                    VStack(spacing: 16) {
                        // Trial offer banner
                        TrialOfferBanner()

                        // Monthly — BEST VALUE (shown first, pre-selected)
                        TierCard(
                            name: "Monthly",
                            price: "$6.99",
                            period: "/month",
                            features: [
                                "All premium features",
                                "Unlimited plants & diagnosis",
                                "3-day free trial included"
                            ],
                            isSelected: selectedTier == Constants.Subscription.ProductID.monthly,
                            onSelect: { selectedTier = Constants.Subscription.ProductID.monthly },
                            isFeatured: true,
                            isBestValue: true
                        )

                        // Yearly — save ~40%
                        TierCard(
                            name: "Yearly",
                            price: "$49.99",
                            period: "/year",
                            features: [
                                "All premium features",
                                "~$4.17/month billed annually",
                                "Save ~40% vs monthly"
                            ],
                            isSelected: selectedTier == Constants.Subscription.ProductID.yearly,
                            onSelect: { selectedTier = Constants.Subscription.ProductID.yearly }
                        )

                        // Lifetime — pay once
                        TierCard(
                            name: "Lifetime",
                            price: "$79.99",
                            period: "once",
                            features: [
                                "All premium features, forever",
                                "Pay once, own forever",
                                "All future updates included"
                            ],
                            isSelected: selectedTier == Constants.Subscription.ProductID.lifetime,
                            onSelect: { selectedTier = Constants.Subscription.ProductID.lifetime }
                        )

                        // Weekly — flexible
                        TierCard(
                            name: "Weekly",
                            price: "$4.99",
                            period: "/week",
                            features: [
                                "All premium features",
                                "Most flexible option",
                                "Cancel anytime"
                            ],
                            isSelected: selectedTier == Constants.Subscription.ProductID.weekly,
                            onSelect: { selectedTier = Constants.Subscription.ProductID.weekly }
                        )
                    }
                }

                // CTA Button
                Button(action: purchasePlan) {
                    if isLoading {
                        ProgressView()
                            .tint(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    } else {
                        Text(ctaTitle)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.black)
                            .background(AppBrand.primary)
                            .cornerRadius(14)
                    }
                }
                .disabled(isLoading)

                // Footer
                VStack(spacing: 8) {
                    Text(footerText)
                        .font(.caption)
                        .foregroundColor(AppText.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Secure payment via App Store")
                            .font(.caption2)
                    }
                    .foregroundColor(AppText.tertiary)
                }
            }
            .padding(24)
        }
    }

    private func purchasePlan() {
        isLoading = true
        // RevenueCat will handle the purchase flow
        onComplete(selectedTier)
    }
}

// MARK: - Helper Components

struct TrialOfferBanner: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Try Premium Free")
                        .font(.headline)
                        .foregroundColor(AppText.primary)
                    Text("3 days, no credit card required")
                        .font(.caption)
                        .foregroundColor(AppText.secondary)
                }

                Spacer()

                Text("3")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppBrand.primary)
            }
            .padding(16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppBrand.primary.opacity(0.1),
                        AppBrand.secondary.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppBrand.primary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct TierCard: View {
    let name: String
    let price: String
    let period: String
    let features: [String]
    let isSelected: Bool
    let onSelect: () -> Void
    var isFeatured: Bool = false
    var isBestValue: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(AppText.primary)

                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }

                    HStack(spacing: 0) {
                        Text(price)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppText.primary)
                        Text(period)
                            .font(.caption)
                            .foregroundColor(AppText.secondary)
                    }
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? AppBrand.primary : AppText.tertiary,
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(AppBrand.primary)
                            .frame(width: 12, height: 12)
                    }
                }
                .onTapGesture(perform: onSelect)
            }

            // Features
            VStack(spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppBrand.primary)

                        Text(feature)
                            .font(.body)
                            .foregroundColor(AppText.secondary)

                        Spacer()
                    }
                }
            }

            // Selection button
            Button(action: onSelect) {
                Text("Select Plan")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(isSelected ? .black : AppBrand.primary)
                    .background(
                        isSelected ?
                        AppBrand.primary :
                        AppBrand.primary.opacity(0.1)
                    )
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(isFeatured ? AppBrand.primary.opacity(0.05) : AppSurface.tertiary)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFeatured ? AppBrand.primary.opacity(0.3) : AppText.tertiary.opacity(0.3),
                    lineWidth: isFeatured ? 2 : 1
                )
        )
    }
}

#Preview {
    ModernPaywallView(onComplete: { _ in })
        .environmentObject(RevenueCatManager.shared)
}
