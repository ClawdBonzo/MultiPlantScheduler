import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var monthlyPackage: Package? {
        revenueCatManager.offerings?.current?.monthly
    }

    var annualPackage: Package? {
        revenueCatManager.offerings?.current?.annual
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with gradient
                VStack(spacing: 20) {
                    Text("🌿")
                        .font(.system(size: 64))

                    VStack(spacing: 8) {
                        Text("Unlock Unlimited Plants")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Premium features for the plant lover in you")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.forestGreen.opacity(0.3),
                            AppColors.background
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                ScrollView {
                    VStack(spacing: 24) {
                        // Benefits
                        VStack(spacing: 12) {
                            BenefitRow(
                                icon: "leaf.fill",
                                title: "Unlimited Plants",
                                subtitle: "Track as many plants as you want"
                            )

                            BenefitRow(
                                icon: "calendar",
                                title: "Seasonal Auto-Adjust",
                                subtitle: "Smart watering intervals by season"
                            )

                            BenefitRow(
                                icon: "square.and.arrow.up",
                                title: "Export Care History",
                                subtitle: "Download your plant care logs"
                            )

                            BenefitRow(
                                icon: "sparkles",
                                title: "Priority Features",
                                subtitle: "Early access to new features"
                            )
                        }
                        .padding(16)
                        .background(Color(red: 0.118, green: 0.118, blue: 0.118))
                        .cornerRadius(12)

                        // Pricing options
                        VStack(spacing: 12) {
                            if let monthlyPackage = monthlyPackage {
                                PricingOptionButton(
                                    package: monthlyPackage,
                                    isSelected: false,
                                    badge: nil,
                                    action: {
                                        purchasePackage(monthlyPackage)
                                    }
                                )
                            }

                            if let annualPackage = annualPackage {
                                PricingOptionButton(
                                    package: annualPackage,
                                    isSelected: true,
                                    badge: "Save 33%",
                                    action: {
                                        purchasePackage(annualPackage)
                                    }
                                )
                            }
                        }

                        // CTA buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await startFreeTrial()
                                }
                            }) {
                                Text("Start 14-Day Free Trial")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppColors.limeGreen)
                                    .cornerRadius(10)
                            }
                            .disabled(isLoading)
                            .opacity(isLoading ? 0.6 : 1)

                            Button(action: { dismiss() }) {
                                Text("Continue with Free (5 plants)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.limeGreen)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(AppColors.forestGreen.opacity(0.2))
                                    .cornerRadius(10)
                            }

                            Button(action: {
                                Task {
                                    let _ = try? await revenueCatManager.restorePurchases()
                                    if revenueCatManager.isPremium {
                                        dismiss()
                                    }
                                }
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        // Legal note
                        VStack(spacing: 4) {
                            Text("By purchasing, you agree to our Terms of Service")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)

                            Text("All subscriptions auto-renew. Cancel anytime in Settings.")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(20)
                }
            }

            if isLoading {
                ZStack {
                    AppColors.background.opacity(0.9)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(AppColors.limeGreen)

                        Text("Processing...")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func purchasePackage(_ package: Package) {
        Task {
            isLoading = true

            do {
                _ = try await revenueCatManager.purchase(package: package)
                isLoading = false
                dismiss()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func startFreeTrial() async {
        isLoading = true

        if let monthlyPackage = monthlyPackage {
            do {
                _ = try await revenueCatManager.purchase(package: monthlyPackage)
                isLoading = false
                dismiss()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.limeGreen)
                .frame(width: 32, height: 32)
                .background(AppColors.limeGreen.opacity(0.2))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
    }
}

struct PricingOptionButton: View {
    let package: Package
    let isSelected: Bool
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(package.packageType == .monthly ? "Monthly" : "Yearly")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)

                            if let price = package.localizedPriceString as String? {
                                Text("\(price)/month")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        Spacer()

                        Text(package.localizedPriceString)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.limeGreen)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(isSelected ? AppColors.forestGreen.opacity(0.3) : Color(red: 0.118, green: 0.118, blue: 0.118))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? AppColors.limeGreen : Color.clear, lineWidth: 2)
                )

                if let badge = badge {
                    Text(badge)
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.urgencyYellow)
                        .cornerRadius(6)
                        .padding(8)
                }
            }
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(RevenueCatManager.shared)
}
