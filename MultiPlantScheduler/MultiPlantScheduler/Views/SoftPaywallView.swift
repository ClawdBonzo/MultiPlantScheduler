import SwiftUI
import RevenueCat

/// Conversion-optimized paywall showing monthly + yearly plans with real pricing
struct SoftPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @State private var selectedPlan: PlanType = .yearly
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var offerings: Offerings?

    enum PlanType { case monthly, yearly }

    private var monthlyPackage: Package? {
        offerings?.current?.monthly
    }

    private var yearlyPackage: Package? {
        offerings?.current?.annual
    }

    private var monthlyPrice: String {
        monthlyPackage?.storeProduct.localizedPriceString ?? "$4.99"
    }

    private var yearlyPrice: String {
        yearlyPackage?.storeProduct.localizedPriceString ?? "$39.99"
    }

    private var yearlyMonthlyEquivalent: String {
        if let product = yearlyPackage?.storeProduct {
            let monthly = product.price as Decimal / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatter?.locale ?? .current
            return formatter.string(from: monthly as NSDecimalNumber) ?? "$3.33"
        }
        return "$3.33"
    }

    private var savingsPercent: Int {
        guard let monthly = monthlyPackage?.storeProduct.price as Decimal?,
              let yearly = yearlyPackage?.storeProduct.price as Decimal? else {
            return 33
        }
        let monthlyAnnual = monthly * 12
        guard monthlyAnnual > 0 else { return 0 }
        let savings = ((monthlyAnnual - yearly) / monthlyAnnual) * 100
        return Int(truncating: savings as NSDecimalNumber)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Dismiss bar
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("🌿")
                                .font(.system(size: 56))

                            Text("Unlock Your Full Garden")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Everything you need to keep your plants thriving")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        // Features
                        VStack(alignment: .leading, spacing: 14) {
                            FeatureRow(icon: "infinity", title: "Unlimited Plants", subtitle: "No limits on your garden")
                            FeatureRow(icon: "camera.fill", title: "Photo Timeline", subtitle: "Track growth over time")
                            FeatureRow(icon: "bell.badge", title: "Custom Reminders", subtitle: "Set times per plant")
                            FeatureRow(icon: "square.grid.2x2", title: "Home Screen Widgets", subtitle: "Watering status at a glance")
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        // Plan cards
                        VStack(spacing: 10) {
                            PlanCard(
                                title: "Yearly",
                                price: yearlyPrice,
                                period: "/year",
                                detail: "\(yearlyMonthlyEquivalent)/mo",
                                badge: "SAVE \(savingsPercent)%",
                                isSelected: selectedPlan == .yearly
                            ) { selectedPlan = .yearly }

                            PlanCard(
                                title: "Monthly",
                                price: monthlyPrice,
                                period: "/month",
                                detail: nil,
                                badge: nil,
                                isSelected: selectedPlan == .monthly
                            ) { selectedPlan = .monthly }
                        }

                        // CTA
                        Button { purchase() } label: {
                            Text("Continue")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.limeGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Legal
                        VStack(spacing: 8) {
                            Button { restorePurchases() } label: {
                                Text("Restore Purchases")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }

                            Text("Cancel anytime in Settings. Payment charged to your Apple ID account.")
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                                .multilineTextAlignment(.center)

                            HStack(spacing: 16) {
                                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                            }
                            .font(.caption2)
                            .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 20)
                }
            }

            if isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
            }
        }
        .task { await loadOfferings() }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func loadOfferings() async {
        do {
            let fetchedOfferings = try await Purchases.shared.offerings()
            await MainActor.run { self.offerings = fetchedOfferings }
        } catch {
            print("Failed to load offerings: \(error)")
        }
    }

    private func purchase() {
        let package: Package?
        switch selectedPlan {
        case .monthly: package = monthlyPackage
        case .yearly: package = yearlyPackage
        }
        guard let package else {
            errorMessage = "No subscription available. Please try again later."
            showError = true
            return
        }
        isLoading = true
        Task {
            do {
                let success = try await revenueCatManager.purchase(package: package)
                if success { dismiss() }
            } catch {
                if let rcError = error as? RevenueCat.ErrorCode, rcError == .purchaseCancelledError {
                    // User cancelled — do nothing
                } else {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            isLoading = false
        }
    }

    private func restorePurchases() {
        isLoading = true
        Task {
            do {
                let restored = try await revenueCatManager.restorePurchases()
                if restored { dismiss() }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

// MARK: - Subviews

private struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let detail: String?
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textPrimary)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.limeGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(price)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(period)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isSelected ? 0.08 : 0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.limeGreen : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.limeGreen)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
