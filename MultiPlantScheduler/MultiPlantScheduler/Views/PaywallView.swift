import SwiftUI
import RevenueCat

/// Dashboard paywall — Home AI style with hero, 3-tier pricing, and urgency elements
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

    enum PlanType { case monthly, yearly, lifetime }

    private var monthlyPackage: Package? { offerings?.current?.monthly }
    private var annualPackage: Package? { offerings?.current?.annual }
    private var lifetimePackage: Package? { offerings?.current?.lifetime }

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
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Hero Section
                ZStack(alignment: .topLeading) {
                    // Hero gradient — replace with Image("paywall_hero") for real photography
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.25, blue: 0.08),
                            Color(red: 0.12, green: 0.50, blue: 0.15),
                            Color(red: 0.20, green: 0.65, blue: 0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 56, weight: .light))
                                .foregroundStyle(.white.opacity(0.9))
                            Text("Go Premium")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Unlimited plants, Cloud AI & more")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 220)

                    // Close button
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 12)

                }

                // Sale ribbon banner
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("50% OFF")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                    Text("·")
                        .font(.system(size: 14, weight: .bold))
                    HStack(spacing: 3) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 11, weight: .semibold))
                        Text(String(format: "Ends in %d:%02d", countdownMinutes, countdownSeconds))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.red, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // MARK: - Content Card
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Feature benefits — clean icons
                        VStack(spacing: 14) {
                            PaywallBenefitRow(icon: "leaf.fill", title: "Unlimited Plants", subtitle: "Track your entire collection")
                            PaywallBenefitRow(icon: "cloud.fill", title: "Unlimited Cloud AI IDs", subtitle: "Precise identification powered by Plant.id")
                            PaywallBenefitRow(icon: "camera.viewfinder", title: "On-Device AI + Cloud AI", subtitle: "Dual AI for 99% accuracy on 1000+ species")
                            PaywallBenefitRow(icon: "photo.on.rectangle.angled", title: "Photo Timeline", subtitle: "Track growth over time with photos")
                            PaywallBenefitRow(icon: "bell.badge", title: "Custom Reminder Times", subtitle: "Set per-plant notification schedules")
                            PaywallBenefitRow(icon: "calendar", title: "Seasonal Auto-Adjust", subtitle: "Smart watering by season")
                            PaywallBenefitRow(icon: "square.and.arrow.up", title: "Export Care History", subtitle: "Download your care logs")
                        }
                        .padding(16)
                        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        // 3-tier pricing — Annual first (default selected)
                        VStack(spacing: 8) {
                            PaywallPlanRow(
                                title: "Yearly",
                                price: yearlyPrice,
                                period: "/year",
                                detail: "\(yearlyMonthlyEquivalent)/mo · Save \(savingsPercent)%",
                                badge: "MOST POPULAR",
                                badgeColor: Color(red: 0.133, green: 0.545, blue: 0.133),
                                isSelected: selectedPlan == .yearly
                            ) { selectedPlan = .yearly }

                            PaywallPlanRow(
                                title: "Lifetime",
                                price: lifetimePrice,
                                period: "once",
                                detail: "Pay once, own forever",
                                badge: "BEST LONG-TERM VALUE",
                                badgeColor: Color(red: 0.55, green: 0.42, blue: 0.15),
                                isSelected: selectedPlan == .lifetime
                            ) { selectedPlan = .lifetime }

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
                            Text(selectedPlan == .lifetime ? "Buy Lifetime Access" : "Subscribe Now")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 14).fill(.black))
                        }
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.6 : 1)

                        // Restore Purchases button — App Store requirement
                        Button(action: { restorePurchases() }) {
                            Text("Restore Purchases")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(red: 0.133, green: 0.545, blue: 0.133))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.133, green: 0.545, blue: 0.133), lineWidth: 1.5)
                                )
                        }

                        Button(action: { dismiss() }) {
                            Text("Continue with Free (5 plants, 10 cloud IDs)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.gray)
                        }

                        // Legal
                        VStack(spacing: 4) {
                            Text(selectedPlan == .lifetime
                                 ? "One-time purchase. No subscription."
                                 : "Auto-renewable. Cancel anytime in Settings.")
                                .font(.system(size: 11))
                                .foregroundStyle(.gray)

                            HStack(spacing: 4) {
                                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                                Text("•").foregroundStyle(.gray)
                                Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            }
                            .font(.system(size: 11))
                            .foregroundStyle(.gray)
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
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .task { await loadOfferings() }
        .onAppear { startTimer() }
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
        } catch {
            #if DEBUG
            print("Failed to load offerings: \(error)")
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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.133, green: 0.545, blue: 0.133))
                .frame(width: 32, height: 32)
                .background(Color(red: 0.133, green: 0.545, blue: 0.133).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.15))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
            }
            Spacer()
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

    private let green = Color(red: 0.133, green: 0.545, blue: 0.133)

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(badgeColor ?? green)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    if let detail {
                        Text(detail)
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black)
                    Text(period)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? green.opacity(0.08) : Color(red: 0.97, green: 0.97, blue: 0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? green : .clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(RevenueCatManager.shared)
}
