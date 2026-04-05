import SwiftUI
import RevenueCat

/// Premium paywall — dark luxury design with 3-tier pricing and urgency elements
struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var selectedPlan: PlanType = .yearly
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var offerings: Offerings?
    @State private var countdown: TimeInterval = 15 * 60
    @State private var timer: Timer?
    @State private var animateHero = false

    enum PlanType { case monthly, yearly, lifetime }

    private var monthlyPackage: Package? { offerings?.current?.monthly }
    private var annualPackage: Package? { offerings?.current?.annual }
    private var lifetimePackage: Package? {
        if let pkg = offerings?.current?.lifetime { return pkg }
        return offerings?.current?.availablePackages.first { pkg in
            pkg.packageType == .lifetime ||
            pkg.storeProduct.productIdentifier.lowercased().contains("lifetime")
        }
    }

    private var monthlyPrice: String { monthlyPackage?.storeProduct.localizedPriceString ?? "$3.99" }
    private var yearlyPrice: String { annualPackage?.storeProduct.localizedPriceString ?? "$29.99" }
    private var lifetimePrice: String { lifetimePackage?.storeProduct.localizedPriceString ?? "$49.99" }

    private var yearlyMonthlyEquivalent: String {
        if let product = annualPackage?.storeProduct {
            let monthly = product.price as Decimal / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatter?.locale ?? .current
            return formatter.string(from: monthly as NSDecimalNumber) ?? "$2.50"
        }
        return "$2.50"
    }

    private var savingsPercent: Int {
        guard let monthly = monthlyPackage?.storeProduct.price as Decimal?,
              let yearly = annualPackage?.storeProduct.price as Decimal? else { return 37 }
        let monthlyAnnual = monthly * 12
        guard monthlyAnnual > 0 else { return 0 }
        let savings = ((monthlyAnnual - yearly) / monthlyAnnual) * 100
        return Int(truncating: savings as NSDecimalNumber)
    }

    private var countdownMinutes: Int { Int(countdown) / 60 }
    private var countdownSeconds: Int { Int(countdown) % 60 }

    var body: some View {
        ZStack {
            // Deep dark background
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Hero Section
                ZStack(alignment: .topLeading) {
                    // Gradient hero with ambient glow
                    ZStack {
                        PremiumGradient.paywallHero

                        // Floating ambient particles
                        ParticleGlowView(count: 6, color: AppColors.limeGreen)
                            .opacity(animateHero ? 0.8 : 0)

                        VStack(spacing: 12) {
                            ZStack {
                                // Glow ring
                                Circle()
                                    .fill(AppColors.limeGreen.opacity(0.12))
                                    .frame(width: 90, height: 90)
                                    .scaleEffect(animateHero ? 1.1 : 0.9)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateHero)

                                Image(systemName: "crown.fill")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .yellow.opacity(0.3), radius: 8)
                            }

                            Text("Go Premium")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Unlimited plants, Cloud AI & more")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    .frame(height: 240)

                    // Close button
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 12)
                }

                // Sale ribbon
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("50% OFF")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                    Text("·")
                        .font(.system(size: 14, weight: .bold))
                    HStack(spacing: 3) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 11, weight: .semibold))
                        Text(String(format: NSLocalizedString("Ends in %d:%02d", comment: "Sale countdown"), countdownMinutes, countdownSeconds))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.15, blue: 0.15), Color(red: 0.95, green: 0.45, blue: 0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Feature benefits
                        VStack(spacing: 14) {
                            PaywallBenefitRow(icon: "leaf.fill", title: "Unlimited Plants", subtitle: "Track your entire collection", iconColor: AppColors.emerald)
                            PaywallBenefitRow(icon: "cloud.fill", title: "Unlimited Cloud AI IDs", subtitle: "Precise identification powered by Plant.id", iconColor: AppColors.teal)
                            PaywallBenefitRow(icon: "photo.on.rectangle.angled", title: "Photo Timeline", subtitle: "Track growth over time with photos", iconColor: AppColors.jade)
                            PaywallBenefitRow(icon: "calendar", title: "Seasonal Auto-Adjust", subtitle: "Smart watering by season", iconColor: AppColors.forestGreen)
                            PaywallBenefitRow(icon: "microbe.fill", title: "Disease & Pest Detection", subtitle: "Unlimited AI health scans", iconColor: .purple)
                            PaywallBenefitRow(icon: "chart.bar.fill", title: "Advanced Analytics", subtitle: "Charts, streaks, and insights", iconColor: .blue)
                            PaywallBenefitRow(icon: "person.2.fill", title: "Community Tips & Tricks", subtitle: "Learn from thousands of plant parents", iconColor: .orange)
                            PaywallBenefitRow(icon: "square.and.arrow.up", title: "Full Data Export", subtitle: "CSV export of all plants and care logs", iconColor: AppColors.mint)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                                )
                        )

                        // 3-tier pricing
                        VStack(spacing: 8) {
                            PaywallPlanRow(
                                title: "Yearly",
                                price: yearlyPrice,
                                period: "/year",
                                detail: "\(yearlyMonthlyEquivalent)/mo · Save \(savingsPercent)%",
                                badge: "MOST POPULAR",
                                badgeColor: AppColors.emerald,
                                isSelected: selectedPlan == .yearly
                            ) { selectedPlan = .yearly }

                            if lifetimePackage != nil {
                                PaywallPlanRow(
                                    title: "Lifetime",
                                    price: lifetimePrice,
                                    period: "once",
                                    detail: "Pay once, own forever",
                                    badge: "BEST VALUE",
                                    badgeColor: Color(red: 0.75, green: 0.55, blue: 0.15),
                                    isSelected: selectedPlan == .lifetime
                                ) { selectedPlan = .lifetime }
                            }

                            PaywallPlanRow(
                                title: "Monthly",
                                price: monthlyPrice,
                                period: "/month",
                                detail: nil,
                                badge: nil,
                                badgeColor: nil,
                                isSelected: selectedPlan == .monthly
                            ) { selectedPlan = .monthly }
                        }

                        // CTA
                        Button(action: { purchase() }) {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.black)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                Text(selectedPlan == .lifetime
                                     ? NSLocalizedString("Buy Lifetime Access", comment: "Buy lifetime")
                                     : NSLocalizedString("Subscribe Now", comment: "Subscribe now"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .premiumButton()
                        }
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.7 : 1)

                        // Restore
                        Button(action: { restorePurchases() }) {
                            Text("Restore Purchases")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.emerald)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.emerald.opacity(0.4), lineWidth: 1.5)
                                )
                        }

                        Button(action: { dismiss() }) {
                            Text("Continue with Free (3 plants, 5 cloud IDs)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        // Legal
                        VStack(spacing: 4) {
                            Text(selectedPlan == .lifetime
                                 ? NSLocalizedString("One-time purchase. No subscription.", comment: "Lifetime legal")
                                 : NSLocalizedString("Auto-renewable. Cancel anytime in Settings.", comment: "Subscription legal"))
                                .font(.system(size: 11))
                                .foregroundStyle(AppColors.textSecondary.opacity(0.6))

                            HStack(spacing: 4) {
                                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                                Text("•").foregroundStyle(AppColors.textSecondary.opacity(0.4))
                                Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            }
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                        }
                    }
                    .padding(20)
                }
            }

            if isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                    Text("Processing...")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .task { await loadOfferings() }
        .onAppear {
            startTimer()
            withAnimation(.easeOut(duration: 1.0)) { animateHero = true }
        }
        .onDisappear { timer?.invalidate() }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 { countdown -= 1 } else { countdown = 15 * 60 }
        }
    }

    private func loadOfferings() async {
        do {
            let fetchedOfferings = try await Purchases.shared.offerings()
            await MainActor.run { self.offerings = fetchedOfferings }
            #if DEBUG
            if let offering = fetchedOfferings.current {
                print("💰 RevenueCat — offering '\(offering.identifier)' loaded with \(offering.availablePackages.count) packages:")
                for pkg in offering.availablePackages {
                    print("  💰 Package: \(pkg.identifier) | type: \(pkg.packageType) | product: \(pkg.storeProduct.productIdentifier) | price: \(pkg.storeProduct.localizedPriceString)")
                }
                print("  💰 .monthly: \(offering.monthly?.storeProduct.productIdentifier ?? "nil")")
                print("  💰 .annual: \(offering.annual?.storeProduct.productIdentifier ?? "nil")")
                print("  💰 .lifetime: \(offering.lifetime?.storeProduct.productIdentifier ?? "nil")")
            } else {
                print("💰 RevenueCat — no current offering found")
            }
            #endif
        } catch {
            #if DEBUG
            print("💰 RevenueCat — failed to load offerings: \(error)")
            #endif
        }
    }

    private func purchase() {
        let package: Package?
        switch selectedPlan {
        case .monthly: package = monthlyPackage
        case .yearly: package = annualPackage
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
                    // cancelled
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

private struct PaywallBenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = AppColors.emerald

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [iconColor, iconColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(iconColor.opacity(0.6))
        }
    }
}

private struct PaywallPlanRow: View {
    let title: String
    let price: String
    let period: String
    let detail: String?
    let badge: String?
    let badgeColor: Color?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(badgeColor ?? AppColors.emerald)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    if let detail {
                        Text(detail)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(period)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppColors.emerald.opacity(0.08) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? AppColors.emerald.opacity(0.5) : Color.white.opacity(0.06), lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(RevenueCatManager.shared)
}
