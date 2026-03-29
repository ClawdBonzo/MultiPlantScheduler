import Foundation
import Combine
import RevenueCat

class RevenueCatManager: ObservableObject {
    static let shared = RevenueCatManager()

    @Published var isPremium: Bool = false
    @Published var offerings: Offerings?
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private var isConfigured = false

    private init() {
        // Don't configure here — defer to .onAppear to avoid crash during app launch
    }

    func configure() {
        guard !isConfigured else { return }
        let apiKey = Constants.RevenueCat.apiKey
        guard apiKey != "YOUR_REVENUECAT_API_KEY_HERE" && !apiKey.isEmpty else { return }

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        isConfigured = true
        checkSubscriptionStatus()
    }

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
            } catch {
                print("Error checking subscription: \(error)")
                await MainActor.run { self.error = error }
            }
        }
    }

    func purchase(package: Package) async throws -> Bool {
        await MainActor.run { self.isLoading = true }
        defer { Task { await MainActor.run { self.isLoading = false } } }

        let result = try await Purchases.shared.purchase(package: package)
        let isPremium = result.customerInfo.entitlements[
            Constants.RevenueCat.premiumEntitlementID
        ]?.isActive ?? false

        await MainActor.run { self.isPremium = isPremium }
        return isPremium
    }

    func restorePurchases() async throws -> Bool {
        await MainActor.run { self.isLoading = true }
        defer { Task { await MainActor.run { self.isLoading = false } } }

        let customerInfo = try await Purchases.shared.restorePurchases()
        let isPremium = customerInfo.entitlements[
            Constants.RevenueCat.premiumEntitlementID
        ]?.isActive ?? false

        await MainActor.run { self.isPremium = isPremium }
        return isPremium
    }

    var plantLimit: Int {
        isPremium ? Int.max : Constants.Subscription.freeTierPlantLimit
    }

    func canAddPlant(currentCount: Int) -> Bool {
        currentCount < plantLimit
    }
}
