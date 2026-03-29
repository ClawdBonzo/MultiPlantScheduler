import SwiftUI
import RevenueCat

/// Home AI-style onboarding paywall with hero visuals, countdown timer, and free trial toggle
struct SoftPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var offerings: Offerings?
    @State private var freeTrialEnabled = true
    @State private var countdown: TimeInterval = 15 * 60 // 15 minutes
    @State private var timer: Timer?

    private var yearlyPackage: Package? {
        offerings?.current?.annual
    }

    private var monthlyPackage: Package? {
        offerings?.current?.monthly
    }

    private var lifetimePackage: Package? {
        offerings?.current?.lifetime
    }

    private var displayPrice: String {
        if freeTrialEnabled {
            return monthlyPackage?.storeProduct.localizedPriceString ?? "$3.99"
        } else {
            return yearlyPackage?.storeProduct.localizedPriceString ?? "$29.99"
        }
    }

    private var displayPeriod: String {
        freeTrialEnabled ? "/month" : "/year"
    }

    private var originalPrice: String {
        // Show a "was" price for the flash sale
        "$59.99"
    }

    private var countdownMinutes: Int { Int(countdown) / 60 }
    private var countdownSeconds: Int { Int(countdown) % 60 }
    private var countdownMs: Int { Int((countdown.truncatingRemainder(dividingBy: 1)) * 100) }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Hero Image Section (top ~55%)
                ZStack(alignment: .topLeading) {
                    // Hero visual — replace with Image("paywall_hero").resizable().aspectRatio(contentMode: .fill) when you have a real photo
                    PaywallHeroView()
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.48)
                        .clipped()

                    // Dismiss X
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

                    // Flash sale badge (top right)
                    VStack(spacing: 2) {
                        Text("50%")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.white)
                        Text("OFF")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        HStack(spacing: 2) {
                            Image(systemName: "hourglass")
                                .font(.system(size: 9))
                            Text(String(format: "%d:%02d", countdownMinutes, countdownSeconds))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                        .foregroundStyle(.white)
                    }
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.red)
                            .shadow(color: .red.opacity(0.4), radius: 8, y: 4)
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    .padding(.top, UIScreen.main.bounds.height * 0.32)
                }

                // MARK: - Bottom Card (white, rounded top)
                VStack(spacing: 20) {
                    // Flash sale header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Flash Sale")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("50 % OFF")
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red)
                        )

                        Spacer()

                        // Price with strikethrough
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(originalPrice)
                                .font(.system(size: 14, weight: .medium))
                                .strikethrough()
                                .foregroundStyle(.gray)
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text(displayPrice)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.black)
                                Text(displayPeriod)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }

                    // Countdown timer
                    HStack(spacing: 6) {
                        TimerDigitPair(value: countdownMinutes, label: "MINUTES")
                        Text(":")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.3))
                        TimerDigitPair(value: countdownSeconds, label: "SECONDS")
                        Text(":")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.3))
                        TimerDigitPair(value: countdownMs, label: "MS")
                    }

                    // Free trial toggle
                    if freeTrialEnabled {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Free Trial Enabled")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.black)
                                Spacer()
                                Toggle("", isOn: $freeTrialEnabled)
                                    .labelsHidden()
                                    .tint(Color(red: 0.133, green: 0.545, blue: 0.133))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // Timeline
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 5)
                                        Text("Due today")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.black)
                                    }
                                    Rectangle()
                                        .fill(.black)
                                        .frame(width: 1, height: 16)
                                        .padding(.leading, 3.5)
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle()
                                            .stroke(.black, lineWidth: 1)
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 5)
                                        Text("Due \(trialEndDate)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.black)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 0) {
                                    HStack(spacing: 4) {
                                        Text("3 days free")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color(red: 0.133, green: 0.545, blue: 0.133))
                                        Text("$0.00")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.black)
                                    }
                                    Spacer()
                                    Text(displayPrice)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.black)
                                }
                            }
                            .padding(.horizontal, 8)
                            .frame(height: 52)
                        }
                    } else {
                        // No trial — show yearly plan highlighted
                        HStack {
                            Text("Free Trial Disabled")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.black)
                            Spacer()
                            Toggle("", isOn: $freeTrialEnabled)
                                .labelsHidden()
                                .tint(Color(red: 0.133, green: 0.545, blue: 0.133))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // CTA button
                    Button { purchase() } label: {
                        Text(freeTrialEnabled ? "Try for Free" : "Continue")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.black)
                            )
                    }

                    // Legal footer
                    HStack(spacing: 4) {
                        Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                        Text("•").foregroundStyle(.gray)
                        Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        Text("•").foregroundStyle(.gray)
                        Button("Restore") { restorePurchases() }
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
                )
                .offset(y: -24) // Overlap onto hero
            }

            if isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
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

    private var trialEndDate: String {
        let date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 0.05
            } else {
                countdown = 15 * 60 // Reset
            }
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
        if freeTrialEnabled {
            package = monthlyPackage
        } else {
            package = yearlyPackage
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

// MARK: - Timer Digit Pair

private struct TimerDigitPair: View {
    let value: Int
    let label: String

    private var tens: Int { value / 10 }
    private var ones: Int { value % 10 }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                TimerDigit(digit: tens)
                TimerDigit(digit: ones)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.gray)
        }
    }
}

private struct TimerDigit: View {
    let digit: Int

    var body: some View {
        Text("\(digit)")
            .font(.system(size: 28, weight: .bold, design: .monospaced))
            .foregroundStyle(.black)
            .frame(width: 32, height: 44)
            .background(Color(red: 0.94, green: 0.94, blue: 0.94))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Hero View (replace with real plant photography)

private struct PaywallHeroView: View {
    var body: some View {
        // TODO: Replace this with Image("paywall_hero").resizable().aspectRatio(contentMode: .fill)
        // Use a beautiful, high-res photo of lush indoor plants (e.g. monstera, ferns, pothos on a shelf)
        ZStack {
            // Rich botanical gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.25, blue: 0.08),
                    Color(red: 0.08, green: 0.40, blue: 0.12),
                    Color(red: 0.12, green: 0.55, blue: 0.18),
                    Color(red: 0.20, green: 0.65, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative plant silhouettes
            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    // Left plant cluster
                    VStack(spacing: -10) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .rotationEffect(.degrees(-30))
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48))
                            .rotationEffect(.degrees(15))
                    }
                    .foregroundStyle(.white.opacity(0.15))
                    .padding(.leading, 20)

                    Spacer()

                    // Center content
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(.white.opacity(0.9))

                        Text("MultiPlant AI")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Identify & Care for Your Plants")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.bottom, 60)

                    Spacer()

                    // Right plant cluster
                    VStack(spacing: -10) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 52))
                            .rotationEffect(.degrees(25))
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 40))
                            .rotationEffect(.degrees(-20))
                    }
                    .foregroundStyle(.white.opacity(0.12))
                    .padding(.trailing, 20)
                }
            }
        }
    }
}
