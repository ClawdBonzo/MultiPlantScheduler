import SwiftUI
import RevenueCat

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
        monthlyPackage?.storeProduct.localizedPriceString ?? String(format: "$%.2f", Constants.Subscription.monthlyPrice)
    }

    private var yearlyPrice: String {
        yearlyPackage?.storeProduct.localizedPriceString ?? String(format: "$%.2f", Constants.Subscription.yearlyPrice)
    }

    private var yearlyMonthlyEquivalent: String {
        if let product = yearlyPackage?.storeProduct {
            let monthly = product.price as Decimal / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatter?.locale ?? .current
            return formatter.string(from: monthly as NSDecimalNumber) ?? String(format: "$%.2f", Constants.Subscription.yearlyPrice / 12)
        }
        return String(format: "$%.2f", Constants.Subscription.yearlyPrice / 12)
    }

    private var savingsPercent: Int {
        if let monthly = monthlyPackage?.storeProduct.price as? Decimal,
           let yearly = yearlyPackage?.storeProduct.price as? Decimal {
            let annualFromMonthly = monthly * 12
            guard annualFromMonthly > 0 else { return 0 }
            let savings = ((annualFromMonthly - yearly) / annualFromMonthly) * 100
            return Int(truncating: savings as NSDecimalNumber)
        }
        let annualFromMonthly = Constants.Subscription.monthlyPrice * 12
        let savings = ((annualFromMonthly - Constants.Subscription.yearlyPrice) / annualFromMonthly) * 100
        return Int(savings)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    dismissBar

                    headerSection

                    featuresSection

                    plansSection

                    ctaButton

                    legalSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }

            if isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(AppColors.limeGreen)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadOfferings()
        }
    }

    // MARK: - Dismiss Bar

    private var dismissBar: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                    .padding(8)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Unlock Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textPrimary)

            Text("Everything you need to keep your plants thriving")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            FeatureRow(icon: "infinity", title: "Unlimited Plants", subtitle: "No cap on your garden size")
            FeatureRow(icon: "camera.fill", title: "Photo Timeline", subtitle: "Track growth with photos over time")
            FeatureRow(icon: "bell.badge.fill", title: "Smart Reminders", subtitle: "Custom notification schedules")
            FeatureRow(icon: "square.grid.2x2.fill", title: "Home Screen Widgets", subtitle: "Watering status at a glance")
            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Health Tracking", subtitle: "Monitor plant health trends")
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Plans

    private var plansSection: some View {
        VStack(spacing: 12) {
            // Yearly plan - highlighted
            PlanCard(
                title: "Yearly",
                price: yearlyPrice,
                period: "/year",
                detail: "\(yearlyMonthlyEquivalent)/mo",
                badge: "SAVE \(savingsPercent)%",
                isSelected: selectedPlan == .yearly
            ) {
                selectedPlan = .yearly
            }

            // Monthly plan
            PlanCard(
                title: "Monthly",
                price: monthlyPrice,
                period: "/month",
                detail: nil,
                badge: nil,
                isSelected: selectedPlan == .monthly
            ) {
                selectedPlan = .monthly
            }
        }
    }

    // MARK: - CTA

    private var ctaButton: some View {
        VStack(spacing: 8) {
            Button {
                purchase()
            } label: {
                Text("Start Free Trial")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.limeGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            let trialPrice = selectedPlan == .yearly ? yearlyPrice : monthlyPrice
            let trialPeriod = selectedPlan == .yearly ? "/year" : "/month"
            Text("7-day free trial, then \(trialPrice)\(trialPeriod)")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(spacing: 8) {
            Button {
                Task {
                    do {
                        let restored = try await revenueCatManager.restorePurchases()
                        if restored { dismiss() }
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.8))
            }

            HStack(spacing: 16) {
                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                Link("Privacy", destination: URL(string: "https://robgoldstein.dev/multiplant-privacy")!)
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
            }

            Text("Cancel anytime in Settings > Subscriptions")
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
        }
    }

    // MARK: - Actions

    private func loadOfferings() async {
        do {
            let fetched = try await Purchases.shared.offerings()
            await MainActor.run { self.offerings = fetched }
        } catch {
            print("Failed to fetch offerings: \(error)")
        }
    }

    private func purchase() {
        let package: Package?
        switch selectedPlan {
        case .yearly: package = yearlyPackage
        case .monthly: package = monthlyPackage
        }
        guard let package else {
            errorMessage = "Plan not available. Please try again."
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
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppColors.limeGreen)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.limeGreen)
        }
    }
}

// MARK: - Plan Card

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
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        if let badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColors.limeGreen)
                                .clipShape(Capsule())
                        }
                    }
                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 2) {
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
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppColors.limeGreen.opacity(0.08) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppColors.limeGreen : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}
