import Foundation
import Combine
import RevenueCat

/// Manages subscription and premium features via RevenueCat
class RevenueCatManager: ObservableObject {
    static let shared = RevenueCatManager()

    @Published var isPremium: Bool = false {
        didSet {
            // Mirror premium status to shared UserDefaults for widget access
            UserDefaults(suiteName: SharedContainer.appGroupID)?
                .set(isPremium, forKey: "isPremium")
        }
    }
    @Published var offerings: Offerings?
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private var isConfigured = false

    private init() {
        configure()
    }

    /// Configure RevenueCat with the API key
    func configure() {
        let apiKey = Constants.RevenueCat.apiKey
        guard apiKey != "YOUR_REVENUECAT_API_KEY_HERE" && !apiKey.isEmpty else {
            print("⚠️ RevenueCat: Skipping configuration — API key not set. Running in free mode.")
            return
        }
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        isConfigured = true
        checkSubscriptionStatus()
    }

    /// Check the current subscription status
    func checkSubscriptionStatus() {
        guard isConfigured else { return }
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                await MainActor.run {
                    self.isPremium = customerInfo.entitlements[
                        Constants.RevenueCat.premiumEntitlementID
                    ]?.isActive ?? false
                }
                print("Premium status: \(isPremium)")
            } catch {
                print("Error checking subscription status: \(error)")
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    /// Fetch the available offerings
    private func fetchOfferings() async {
        guard isConfigured else { return }
        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.offerings = offerings
            }
        } catch {
            print("Error fetching offerings: \(error)")
            await MainActor.run {
                self.error = error
            }
        }
    }

    /// Purchase a package
    /// - Parameter package: The package to purchase
    /// - Returns: true if purchase was successful, false otherwise
    func purchase(package: Package) async throws -> Bool {
        await MainActor.run {
            self.isLoading = true
        }

        defer {
            Task {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            let isPremium = result.customerInfo.entitlements[
                Constants.RevenueCat.premiumEntitlementID
            ]?.isActive ?? false

            await MainActor.run {
                self.isPremium = isPremium
            }
            return isPremium
        } catch {
            if let rcError = error as? RevenueCat.ErrorCode, rcError == .purchaseCancelledError {
                print("Purchase cancelled by user")
            } else {
                print("Purchase error: \(error)")
            }
            throw error
        }
    }

    /// Restore previous purchases
    /// - Returns: true if restoration was successful and premium is now active
    func restorePurchases() async throws -> Bool {
        await MainActor.run {
            self.isLoading = true
        }

        defer {
            Task {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let isPremium = customerInfo.entitlements[
                Constants.RevenueCat.premiumEntitlementID
            ]?.isActive ?? false

            await MainActor.run {
                self.isPremium = isPremium
            }
            return isPremium
        } catch {
            print("Error restoring purchases: \(error)")
            throw error
        }
    }

    /// Get the maximum number of plants allowed for the current subscription tier
    /// - Returns: 5 for free tier, Int.max for premium
    var plantLimit: Int {
        isPremium ? Int.max : Constants.Subscription.freeTierPlantLimit
    }

    /// Check if a new plant can be added given the current plant count
    /// - Parameter currentCount: The current number of plants
    /// - Returns: true if a new plant can be added, false otherwise
    func canAddPlant(currentCount: Int) -> Bool {
        currentCount < plantLimit
    }

    /// Get the monthly price as a formatted string
    static var monthlyPriceFormatted: String {
        String(format: "$%.2f/month", Constants.Subscription.monthlyPrice)
    }

    /// Get the yearly price as a formatted string
    static var yearlyPriceFormatted: String {
        String(format: "$%.2f/year", Constants.Subscription.yearlyPrice)
    }
}
