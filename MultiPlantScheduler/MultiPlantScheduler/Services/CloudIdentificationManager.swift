import UIKit
import Foundation

/// Manages Plant.id cloud API calls and free credit tracking.
/// Every new user gets 10 free cloud IDs. Premium users get unlimited.
/// The app remains 100% offline-first — cloud is optional for higher accuracy.
final class CloudIdentificationManager {
    static let shared = CloudIdentificationManager()

    // MARK: - Plant.id API Configuration
    // Get your free API key at https://web.plant.id/api-access-request/
    // Free tier: 100 identifications/day — more than enough for testing.
    // Replace this placeholder with your real key:
    private let apiKey = "YOUR_PLANT_ID_API_KEY_HERE"
    private let apiURL = "https://plant.id/api/v3/identification"

    // MARK: - Credit Tracking (UserDefaults)
    private let creditsKey = "cloudIDCreditsRemaining"
    private let initializedKey = "cloudIDCreditsInitialized"
    static let maxFreeCredits = 10

    private init() {
        initializeCreditsIfNeeded()
    }

    /// Initialize credits for first-time users
    private func initializeCreditsIfNeeded() {
        if !UserDefaults.standard.bool(forKey: initializedKey) {
            UserDefaults.standard.set(Self.maxFreeCredits, forKey: creditsKey)
            UserDefaults.standard.set(true, forKey: initializedKey)
        }
    }

    /// Number of free cloud ID credits remaining
    var creditsRemaining: Int {
        UserDefaults.standard.integer(forKey: creditsKey)
    }

    /// Whether the user can use cloud ID (has credits or is premium)
    func canUseCloud(isPremium: Bool) -> Bool {
        return isPremium || creditsRemaining > 0
    }

    /// Whether the API key is configured (not placeholder)
    var isAPIKeyConfigured: Bool {
        apiKey != "YOUR_PLANT_ID_API_KEY_HERE" && !apiKey.isEmpty
    }

    /// Decrement credits (only for free users)
    private func decrementCredits() {
        let current = creditsRemaining
        if current > 0 {
            UserDefaults.standard.set(current - 1, forKey: creditsKey)
        }
    }

    // MARK: - Cloud Identification Result

    struct CloudResult {
        let species: String?
        let commonName: String?
        let confidence: Double
        let description: String?
        let isHealthy: Bool?
        let suggestions: [CloudSuggestion]
    }

    struct CloudSuggestion {
        let scientificName: String
        let commonName: String?
        let confidence: Double
    }

    // MARK: - Plant.id API Call

    /// Identify a plant using the Plant.id cloud API.
    /// Returns nil if API key not configured, no credits, or network error.
    func identifyPlant(from image: UIImage, isPremium: Bool) async -> CloudResult? {
        // Check credits
        guard canUseCloud(isPremium: isPremium) else {
            return nil
        }

        // Check API key
        guard isAPIKeyConfigured else {
            print("Cloud ID: API key not configured — using placeholder")
            return nil
        }

        // Compress image for upload
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        let base64Image = imageData.base64EncodedString()

        // Build request body
        let requestBody: [String: Any] = [
            "images": ["data:image/jpeg;base64,\(base64Image)"],
            "similar_images": true
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return nil
        }

        // Build URL request
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("Cloud ID: API returned status \(statusCode)")
                return nil
            }

            // Parse response
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = json["result"] as? [String: Any],
                  let classification = result["classification"] as? [String: Any],
                  let suggestions = classification["suggestions"] as? [[String: Any]] else {
                print("Cloud ID: Failed to parse response")
                return nil
            }

            // Parse top suggestions
            var cloudSuggestions: [CloudSuggestion] = []
            var topSpecies: String?
            var topCommon: String?
            var topConfidence: Double = 0

            for (index, suggestion) in suggestions.prefix(5).enumerated() {
                let scientificName = suggestion["name"] as? String ?? "Unknown"
                let probability = suggestion["probability"] as? Double ?? 0
                var commonName: String?

                if let details = suggestion["details"] as? [String: Any],
                   let commonNames = details["common_names"] as? [String],
                   let first = commonNames.first {
                    commonName = first
                }

                if index == 0 {
                    topSpecies = scientificName
                    topCommon = commonName
                    topConfidence = probability
                }

                cloudSuggestions.append(CloudSuggestion(
                    scientificName: scientificName,
                    commonName: commonName,
                    confidence: probability
                ))
            }

            // Check health if available
            var isHealthy: Bool?
            if let isHealthyResult = result["is_healthy"] as? [String: Any],
               let healthy = isHealthyResult["binary"] as? Bool {
                isHealthy = healthy
            }

            // Decrement credits for free users
            if !isPremium {
                decrementCredits()
            }

            return CloudResult(
                species: topSpecies,
                commonName: topCommon,
                confidence: topConfidence,
                description: nil,
                isHealthy: isHealthy,
                suggestions: cloudSuggestions
            )

        } catch {
            print("Cloud ID: Network error — \(error.localizedDescription)")
            return nil
        }
    }

    /// Convert a cloud result into the app's standard IdentificationResult format
    func toIdentificationResult(_ cloud: CloudResult) -> PlantIdentifierService.IdentificationResult {
        let displayName = cloud.commonName ?? cloud.species ?? "Unknown"

        // Try to match to our database
        let dbSpecies = PlantSpeciesDatabase.species(named: displayName)
            ?? PlantSpeciesDatabase.search(query: displayName).first

        let interval = dbSpecies?.defaultWateringDays ?? 7
        let mappedName = dbSpecies?.name ?? displayName

        let suggestions: [PlantIdentifierService.Suggestion] = cloud.suggestions.prefix(3).map { s in
            let name = s.commonName ?? s.scientificName
            let db = PlantSpeciesDatabase.species(named: name)
                ?? PlantSpeciesDatabase.search(query: name).first
            return PlantIdentifierService.Suggestion(
                species: db?.name ?? name,
                confidence: s.confidence,
                defaultInterval: db?.defaultWateringDays ?? 7
            )
        }

        return PlantIdentifierService.IdentificationResult(
            species: mappedName,
            confidence: cloud.confidence,
            defaultInterval: interval,
            isLowConfidence: cloud.confidence < 0.70,
            topSuggestions: suggestions
        )
    }
}
