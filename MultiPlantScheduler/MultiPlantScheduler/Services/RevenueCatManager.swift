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
        // Don't configure RevenueCat in init — defer to avoid crash during app launch
    }

    /// Configure RevenueCat with the API key — safe to call multiple times
    func configure() {
        guard !isConfigured else { return }
        let apiKey = Constants.RevenueCat.apiKey
        guard apiKey != "YOUR_REVENUECAT_API_KEY_HERE" && !apiKey.isEmpty else {
            #if DEBUG
            print("⚠️ RevenueCat: Skipping configuration — API key not set. Running in free mode.")
            #endif
            return
        }
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
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
                #if DEBUG
                print("Premium status: \(isPremium)")
                #endif
            } catch {
                #if DEBUG
                print("Error checking subscription status: \(error)")
                #endif
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
            #if DEBUG
            print("Error fetching offerings: \(error)")
            #endif
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
            #if DEBUG
            if let rcError = error as? RevenueCat.ErrorCode, rcError == .purchaseCancelledError {
                print("Purchase cancelled by user")
            } else {
                print("Purchase error: \(error)")
            }
            #endif
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
            #if DEBUG
            print("Error restoring purchases: \(error)")
            #endif
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

    /// Check if the user has a lifetime (non-expiring) entitlement
    func hasLifetime() -> Bool {
        guard isPremium else { return false }
        // Lifetime purchases show as active entitlements with no expiration
        return true // Will be refined when customerInfo is cached
    }

    /// Check if user has lifetime purchase via customerInfo
    func checkLifetimeStatus() async -> Bool {
        guard isConfigured else { return false }
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let entitlement = customerInfo.entitlements[Constants.RevenueCat.premiumEntitlementID]
            // Lifetime = active entitlement with no expiration date
            return entitlement?.isActive == true && entitlement?.expirationDate == nil
        } catch {
            return false
        }
    }

    /// Get the monthly price as a formatted string
    static var monthlyPriceFormatted: String {
        String(format: "$%.2f/month", Constants.Subscription.monthlyPrice)
    }

    /// Get the yearly price as a formatted string
    static var yearlyPriceFormatted: String {
        String(format: "$%.2f/year", Constants.Subscription.yearlyPrice)
    }

    /// Get the lifetime price as a formatted string
    static var lifetimePriceFormatted: String {
        String(format: "$%.2f", Constants.Subscription.lifetimePrice)
    }
}
