import SwiftUI
import RevenueCat

/// Premium paywall — dark glassmorphism design, 4-tier pricing, correct trial info
struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var selectedPlan: PlanType = .monthly
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var offerings: Offerings?
    @State private var animateHero = false

    enum PlanType: CaseIterable { case monthly, yearly, lifetime, weekly }

    // MARK: - Package Resolution

    private var weeklyPackage: Package? {
        offerings?.current?.availablePackages.first {
            $0.packageType == .weekly ||
            $0.storeProduct.productIdentifier == Constants.Subscription.ProductID.weekly
        }
    }
    private var monthlyPackage: Package? { offerings?.current?.monthly }
    private var annualPackage: Package? { offerings?.current?.annual }
    private var lifetimePackage: Package? {
        if let pkg = offerings?.current?.lifetime { return pkg }
        return offerings?.current?.availablePackages.first {
            $0.packageType == .lifetime ||
            $0.storeProduct.productIdentifier == Constants.Subscription.ProductID.lifetime
        }
    }

    // MARK: - Derived Prices (RevenueCat → fallback)

    private var weeklyPrice: String  { weeklyPackage?.storeProduct.localizedPriceString   ?? "$4.99" }
    private var monthlyPrice: String { monthlyPackage?.storeProduct.localizedPriceString  ?? "$6.99" }
    private var yearlyPrice: String  { annualPackage?.storeProduct.localizedPriceString   ?? "$49.99" }
    private var lifetimePrice: String { lifetimePackage?.storeProduct.localizedPriceString ?? "$79.99" }

    private var yearlyMonthlyEquivalent: String {
        if let product = annualPackage?.storeProduct {
            let monthly = product.price as Decimal / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatter?.locale ?? .current
            return formatter.string(from: monthly as NSDecimalNumber) ?? "$4.17"
        }
        return "$4.17"
    }

    private var savingsPercent: Int {
        guard let monthlyProduct = monthlyPackage?.storeProduct,
              let annualProduct = annualPackage?.storeProduct else { return 40 }
        let monthlyPerYear = Double(truncating: monthlyProduct.price as NSDecimalNumber) * 12
        let yearly = Double(truncating: annualProduct.price as NSDecimalNumber)
        guard monthlyPerYear > 0 else { return 40 }
        return Int(((monthlyPerYear - yearly) / monthlyPerYear) * 100)
    }

    // MARK: - CTA & Legal (trial-aware)

    private var ctaButtonTitle: String {
        switch selectedPlan {
        case .monthly:  return "Start 3-Day Free Trial"
        case .yearly:   return "Start 3-Day Free Trial"
        case .weekly:   return "Subscribe Weekly"
        case .lifetime: return "Buy Lifetime Access"
        }
    }

    private var legalFooterText: String {
        switch selectedPlan {
        case .monthly:
            return "3-day free trial, then \(monthlyPrice)/month. Cancel anytime."
        case .yearly:
            return "3-day free trial, then \(yearlyPrice)/year. Cancel anytime."
        case .weekly:
            return "\(weeklyPrice)/week. Auto-renews. Cancel anytime."
        case .lifetime:
            return "One-time purchase of \(lifetimePrice). No subscription."
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Hero
                ZStack(alignment: .topLeading) {
                    ZStack {
                        PremiumGradient.paywallHero

                        ParticleGlowView(count: 5, color: AppColors.limeGreen)
                            .opacity(animateHero ? 0.7 : 0)

                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.10))
                                    .frame(width: 52, height: 52)
                                    .scaleEffect(animateHero ? 1.08 : 0.92)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateHero)

                                Image(systemName: "crown.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.yellow, .orange],
                                                       startPoint: .top, endPoint: .bottom)
                                    )
                                    .shadow(color: .yellow.opacity(0.3), radius: 6)
                            }

                            Text("Go Premium")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(height: 90)

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 28, height: 28)
                            .background(.ultraThinMaterial.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 14)
                    .padding(.top, 10)
                }

                // MARK: Content
                VStack(spacing: 12) {
                    // Features
                    HStack(spacing: 0) {
                        FeatureChip(icon: "leaf.fill", text: "Unlimited Plants", color: AppColors.emerald)
                        FeatureChip(icon: "microbe.fill", text: "AI Diagnosis", color: .purple)
                        FeatureChip(icon: "chart.bar.fill", text: "Analytics", color: .blue)
                        FeatureChip(icon: "calendar", text: "Smart Care", color: AppColors.forestGreen)
                    }
                    .padding(.horizontal, 12)

                    // MARK: Plan Cards
                    VStack(spacing: 6) {
                        // Monthly — BEST VALUE + 3-day trial
                        PlanCard(
                            title: "Monthly",
                            price: monthlyPrice,
                            period: "/mo",
                            trialText: "3-day free trial",
                            badge: "BEST VALUE",
                            badgeColors: (Color(red: 1.0, green: 0.82, blue: 0.28), Color(red: 0.15, green: 0.12, blue: 0.0)),
                            isSelected: selectedPlan == .monthly
                        ) { selectedPlan = .monthly }

                        // Yearly — 3-day trial + savings
                        PlanCard(
                            title: "Yearly",
                            price: yearlyPrice,
                            period: "/yr",
                            trialText: "3-day free trial · \(yearlyMonthlyEquivalent)/mo",
                            badge: "SAVE \(savingsPercent)%",
                            badgeColors: (AppColors.teal, .white),
                            isSelected: selectedPlan == .yearly
                        ) { selectedPlan = .yearly }

                        // Lifetime — no trial
                        PlanCard(
                            title: "Lifetime",
                            price: lifetimePrice,
                            period: " once",
                            trialText: "Pay once, own forever",
                            badge: nil, badgeColors: nil,
                            isSelected: selectedPlan == .lifetime
                        ) { selectedPlan = .lifetime }

                        // Weekly — no trial
                        PlanCard(
                            title: "Weekly",
                            price: weeklyPrice,
                            period: "/wk",
                            trialText: "Most flexible, no commitment",
                            badge: nil, badgeColors: nil,
                            isSelected: selectedPlan == .weekly
                        ) { selectedPlan = .weekly }
                    }
                    .padding(.horizontal, 14)

                    // MARK: CTA
                    Button(action: purchase) {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView().tint(.black).scaleEffect(0.8)
                            } else {
                                Image(systemName: selectedPlan == .monthly || selectedPlan == .yearly
                                      ? "gift.fill" : "crown.fill")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            Text(ctaButtonTitle)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .premiumButton()
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.7 : 1)
                    .padding(.horizontal, 14)

                    // MARK: Footer
                    HStack {
                        Button(action: restorePurchases) {
                            Text("Restore")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.emerald)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Text("Continue Free")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 1) {
                        Text(legalFooterText)
                            .font(.system(size: 9))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                            .multilineTextAlignment(.center)

                        HStack(spacing: 4) {
                            Link("Privacy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                            Text("·").foregroundStyle(AppColors.textSecondary.opacity(0.3))
                            Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        }
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.4))
                    }
                    .padding(.bottom, 4)
                }
                .padding(.top, 8)
            }

            // Loading overlay
            if isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView().tint(.white).scaleEffect(1.3)
            }
        }
        .task { await loadOfferings() }
        .onAppear { withAnimation(.easeOut(duration: 0.8)) { animateHero = true } }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Actions

    private func loadOfferings() async {
        do {
            let fetched = try await Purchases.shared.offerings()
            await MainActor.run { self.offerings = fetched }
            #if DEBUG
            if let offering = fetched.current {
                print("💰 Offering '\(offering.identifier)': \(offering.availablePackages.count) packages")
                for pkg in offering.availablePackages {
                    print("  💰 \(pkg.identifier) → \(pkg.storeProduct.productIdentifier) @ \(pkg.storeProduct.localizedPriceString)")
                }
            }
            #endif
        } catch {
            #if DEBUG
            print("💰 Failed to load offerings: \(error)")
            #endif
        }
    }

    private func purchase() {
        let package: Package?
        switch selectedPlan {
        case .weekly:   package = weeklyPackage
        case .monthly:  package = monthlyPackage
        case .yearly:   package = annualPackage
        case .lifetime: package = lifetimePackage
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
                    // user cancelled
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

// MARK: - Feature Chip (horizontal row)

private struct FeatureChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 26, height: 26)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(text)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let trialText: String
    let badge: String?
    let badgeColors: (bg: Color, fg: Color)?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Radio
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.emerald : Color.white.opacity(0.15), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(AppColors.emerald)
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        if let badge, let colors = badgeColors {
                            Text(badge)
                                .font(.system(size: 8, weight: .heavy, design: .rounded))
                                .foregroundStyle(colors.fg)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(colors.bg)
                                )
                        }
                    }
                    Text(trialText)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(price)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(period)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.emerald.opacity(0.06) : Color.white.opacity(0.025))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? AppColors.emerald.opacity(0.5) : Color.white.opacity(0.06),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
        .environmentObject(RevenueCatManager.shared)
}
