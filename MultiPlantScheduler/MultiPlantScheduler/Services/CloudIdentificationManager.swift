import UIKit
import Foundation

/// Manages Plant.id cloud API calls and free credit tracking.
/// Every new user gets 5 free cloud IDs. Premium users get unlimited.
/// The app remains 100% offline-first — cloud is optional for higher accuracy.
final class CloudIdentificationManager {
    static let shared = CloudIdentificationManager()

    // MARK: - Plant.id API Configuration
    // API key loaded from APIKeys.generated.swift — never commit real keys
    // See Config.example.xcconfig for setup instructions
    private let apiKey: String = APIKeys.plantIDAPIKey
    private let apiURL = "https://plant.id/api/v3/identification"

    // MARK: - Credit Tracking (UserDefaults)
    private let creditsKey = "cloudIDCreditsRemaining"
    private let initializedKey = "cloudIDCreditsInitialized"
    static let maxFreeCredits = 5

    /// Last error message from a cloud call (for UI display)
    private(set) var lastErrorMessage: String?

    private init() {
        initializeCreditsIfNeeded()
        #if DEBUG
        let keyPreview = apiKey.isEmpty ? "(empty)" : String(apiKey.prefix(8)) + "..."
        print("☁️ CloudID init — API key loaded: \(keyPreview)")
        print("☁️ CloudID init — isAPIKeyConfigured: \(isAPIKeyConfigured)")
        print("☁️ CloudID init — credits remaining: \(creditsRemaining)")
        #endif
    }

    /// Initialize credits for first-time users, and cap existing users to current max
    private func initializeCreditsIfNeeded() {
        if !UserDefaults.standard.bool(forKey: initializedKey) {
            UserDefaults.standard.set(Self.maxFreeCredits, forKey: creditsKey)
            UserDefaults.standard.set(true, forKey: initializedKey)
        } else {
            // Cap existing credits to current max (handles downgrade from 10 → 5)
            let current = UserDefaults.standard.integer(forKey: creditsKey)
            if current > Self.maxFreeCredits {
                UserDefaults.standard.set(Self.maxFreeCredits, forKey: creditsKey)
                #if DEBUG
                print("☁️ CloudID — capped credits from \(current) to \(Self.maxFreeCredits)")
                #endif
            }
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

    /// Whether the API key is configured (loaded from xcconfig via Info.plist)
    var isAPIKeyConfigured: Bool {
        !apiKey.isEmpty && apiKey != "YOUR_KEY_HERE"
    }

    /// Reset credits to max (DEBUG only — for testing)
    #if DEBUG
    func resetCredits() {
        UserDefaults.standard.set(Self.maxFreeCredits, forKey: creditsKey)
        print("☁️ CloudID — credits reset to \(Self.maxFreeCredits)")
    }
    #endif

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
        lastErrorMessage = nil

        #if DEBUG
        print("☁️ CloudID — identifyPlant called (isPremium: \(isPremium))")
        print("☁️ CloudID — credits remaining before call: \(creditsRemaining)")
        #endif

        // Check credits
        guard canUseCloud(isPremium: isPremium) else {
            lastErrorMessage = "No cloud credits remaining"
            #if DEBUG
            print("☁️ CloudID — BLOCKED: no credits and not premium")
            #endif
            return nil
        }

        // Check API key
        guard isAPIKeyConfigured else {
            lastErrorMessage = "Cloud AI key not loaded — check Config.xcconfig"
            #if DEBUG
            print("☁️ CloudID — BLOCKED: API key not configured (key is '\(apiKey.isEmpty ? "empty" : apiKey)')")
            #endif
            return nil
        }

        // Compress image for upload
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            lastErrorMessage = "Could not process image"
            #if DEBUG
            print("☁️ CloudID — BLOCKED: failed to create JPEG data from image")
            #endif
            return nil
        }
        let base64Image = imageData.base64EncodedString()

        #if DEBUG
        let imageSizeKB = imageData.count / 1024
        print("☁️ CloudID — image compressed: \(imageSizeKB)KB, base64 length: \(base64Image.count)")
        print("☁️ CloudID — sending request to \(apiURL)...")
        #endif

        // Build request body
        let requestBody: [String: Any] = [
            "images": ["data:image/jpeg;base64,\(base64Image)"],
            "similar_images": true
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            lastErrorMessage = "Could not build request"
            return nil
        }

        // Build URL request
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

            #if DEBUG
            print("☁️ CloudID — response status code: \(statusCode)")
            if let bodySnippet = String(data: data.prefix(500), encoding: .utf8) {
                print("☁️ CloudID — response body snippet: \(bodySnippet)")
            }
            #endif

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                lastErrorMessage = "Plant.id returned error \(statusCode)"
                #if DEBUG
                print("☁️ CloudID — FAILED: non-success status \(statusCode)")
                if let fullBody = String(data: data, encoding: .utf8) {
                    print("☁️ CloudID — full error body: \(fullBody)")
                }
                #endif
                return nil
            }

            // Parse response
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = json["result"] as? [String: Any],
                  let classification = result["classification"] as? [String: Any],
                  let suggestions = classification["suggestions"] as? [[String: Any]] else {
                lastErrorMessage = "Could not parse Plant.id response"
                #if DEBUG
                print("☁️ CloudID — FAILED: could not parse JSON structure")
                if let fullBody = String(data: data, encoding: .utf8) {
                    print("☁️ CloudID — raw response: \(fullBody)")
                }
                #endif
                return nil
            }

            #if DEBUG
            print("☁️ CloudID — parsed OK: \(suggestions.count) suggestions")
            #endif

            // Parse top suggestions
            var cloudSuggestions: [CloudSuggestion] = []
            var topSpecies: String?
            var topCommon: String?
            var topConfidence: Double = 0

            for (index, suggestion) in suggestions.prefix(5).enumerated() {
                let scientificName = suggestion["name"] as? String ?? "Unknown"
                let rawProbability = suggestion["probability"] as? Double ?? 0
                let probability = min(rawProbability, 1.0) // Clamp to 100% max
                var commonName: String?

                if let details = suggestion["details"] as? [String: Any],
                   let commonNames = details["common_names"] as? [String],
                   let first = commonNames.first {
                    commonName = first
                }

                #if DEBUG
                print("☁️ CloudID — suggestion[\(index)]: \(commonName ?? scientificName) (\(Int(probability * 100))%)")
                #endif

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

            // Decrement credits ONLY on successful 200/201 response — for free users only
            if !isPremium {
                decrementCredits()
                #if DEBUG
                print("☁️ CloudID — ✅ SUCCESS: credits decremented → \(creditsRemaining) remaining")
                #endif
            } else {
                #if DEBUG
                print("☁️ CloudID — ✅ SUCCESS: premium user, no credit decrement")
                #endif
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
            lastErrorMessage = "Network error: \(error.localizedDescription)"
            #if DEBUG
            print("☁️ CloudID — NETWORK ERROR: \(error.localizedDescription)")
            print("☁️ CloudID — error type: \(type(of: error))")
            #endif
            return nil
        }
    }

    /// Test the API connection without decrementing credits (DEBUG only)
    #if DEBUG
    func debugTestAPICall() async -> String {
        let keyPreview = apiKey.isEmpty ? "(empty)" : String(apiKey.prefix(8)) + "..."
        var output = "=== Cloud API Debug ===\n"
        output += "API Key: \(keyPreview)\n"
        output += "Key configured: \(isAPIKeyConfigured)\n"
        output += "Credits remaining: \(creditsRemaining)\n"
        output += "URL: \(apiURL)\n\n"

        guard isAPIKeyConfigured else {
            output += "❌ API key not configured! Check Config.xcconfig.\n"
            output += "Raw key value: '\(apiKey)'\n"
            return output
        }

        // Tiny 1x1 white pixel JPEG for minimal bandwidth test
        let tinyImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            UIColor.green.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        guard let imageData = tinyImage.jpegData(compressionQuality: 0.1) else {
            output += "❌ Could not create test image\n"
            return output
        }

        let base64Image = imageData.base64EncodedString()
        let requestBody: [String: Any] = [
            "images": ["data:image/jpeg;base64,\(base64Image)"],
            "similar_images": true
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            output += "❌ Could not build request\n"
            return output
        }

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15

        output += "Sending test request...\n"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            output += "Status code: \(statusCode)\n"

            if let bodyStr = String(data: data.prefix(800), encoding: .utf8) {
                output += "Response:\n\(bodyStr)\n"
            }

            if statusCode == 200 || statusCode == 201 {
                output += "\n✅ API connection works! Credits on Plant.id dashboard should decrement.\n"
            } else if statusCode == 401 {
                output += "\n❌ 401 Unauthorized — API key is invalid or expired.\n"
            } else if statusCode == 429 {
                output += "\n⚠️ 429 Rate limited — too many requests.\n"
            } else {
                output += "\n⚠️ Unexpected status \(statusCode)\n"
            }
        } catch {
            output += "❌ Network error: \(error.localizedDescription)\n"
        }

        output += "\n(No app credits were decremented for this test call)"
        return output
    }
    #endif

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

        let clampedConfidence = min(cloud.confidence, 1.0)
        return PlantIdentifierService.IdentificationResult(
            species: mappedName,
            confidence: clampedConfidence,
            defaultInterval: interval,
            isLowConfidence: clampedConfidence < 0.70,
            topSuggestions: suggestions
        )
    }
}
