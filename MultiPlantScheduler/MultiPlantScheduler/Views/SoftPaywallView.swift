import SwiftUI
import RevenueCat

/// Soft paywall shown after onboarding to introduce premium features
struct SoftPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var monthlyPackage: Package? {
        revenueCatManager.offerings?.current?.monthly
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("🌿")
                            .font(.system(size: 60))

                        Text("Start Your Plant Journey")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Unlock everything to keep your plants thriving")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    // Premium features
                    VStack(alignment: .leading, spacing: 16) {
                        SoftPaywallFeatureRow(
                            icon: "square.grid.2x2",
                            title: "Home Screen Widgets",
                            description: "See watering status at a glance"
                        )
                        SoftPaywallFeatureRow(
                            icon: "camera.fill",
                            title: "Photo Timeline",
                            description: "Track your plant's growth over time"
                        )
                        SoftPaywallFeatureRow(
                            icon: "bell.badge",
                            title: "Custom Reminders",
                            description: "Set notification times per plant"
                        )
                        SoftPaywallFeatureRow(
                            icon: "infinity",
                            title: "Unlimited Plants",
                            description: "No limits on your garden"
                        )
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // CTA
                    VStack(spacing: 12) {
                        Button {
                            startTrial()
                        } label: {
                            Text("Start 14-Day Free Trial")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.limeGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("Continue with Free Plan")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }

                    Text("Cancel anytime. No commitment.")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal)
            }

            if isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Processing...")
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func startTrial() {
        guard let package = monthlyPackage else {
            dismiss()
            return
        }
        isLoading = true
        Task {
            do {
                let success = try await revenueCatManager.purchase(package: package)
                if success { dismiss() }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

/// Feature row for the soft paywall
struct SoftPaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppColors.limeGreen)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
