import UIKit
import Foundation

/// Manages plant disease and pest detection using Plant.id Health Assessment API.
/// Leverages the same API key and credit system as CloudIdentificationManager.
final class DiagnosisService {
    static let shared = DiagnosisService()

    private let apiURL = "https://plant.id/api/v3/health_assessment"
    private let cloudManager = CloudIdentificationManager.shared

    // MARK: - Credit Tracking (shared with cloud ID)
    private let diagnosisCreditsKey = "diagnosisCreditsRemaining"
    private let diagnosisInitializedKey = "diagnosisCreditsInitialized"
    static let maxFreeDiagnoses = 3

    private init() {
        initializeCreditsIfNeeded()
        #if DEBUG
        print("🔬 DiagnosisService init — credits remaining: \(creditsRemaining)")
        #endif
    }

    private func initializeCreditsIfNeeded() {
        if !UserDefaults.standard.bool(forKey: diagnosisInitializedKey) {
            UserDefaults.standard.set(Self.maxFreeDiagnoses, forKey: diagnosisCreditsKey)
            UserDefaults.standard.set(true, forKey: diagnosisInitializedKey)
        }
    }

    /// Number of free diagnosis credits remaining
    var creditsRemaining: Int {
        UserDefaults.standard.integer(forKey: diagnosisCreditsKey)
    }

    /// Whether the user can run a diagnosis
    func canDiagnose(isPremium: Bool) -> Bool {
        return isPremium || creditsRemaining > 0
    }

    private func decrementCredits() {
        let current = creditsRemaining
        if current > 0 {
            UserDefaults.standard.set(current - 1, forKey: diagnosisCreditsKey)
        }
    }

    #if DEBUG
    func resetCredits() {
        UserDefaults.standard.set(Self.maxFreeDiagnoses, forKey: diagnosisCreditsKey)
        print("🔬 DiagnosisService — credits reset to \(Self.maxFreeDiagnoses)")
    }
    #endif

    // MARK: - Diagnosis Result

    struct DiagnosisResult {
        let isHealthy: Bool
        let healthProbability: Double  // Probability plant is healthy
        let diseases: [DetectedIssue]

        struct DetectedIssue {
            let name: String
            let scientificName: String?
            let probability: Double
            let category: String       // "disease", "pest", "abiotic"
            let description: String?
            let treatment: Treatment?
            let commonNames: [String]

            struct Treatment {
                let biological: [String]
                let chemical: [String]
                let prevention: [String]
            }
        }
    }

    // MARK: - Health Assessment API Call

    /// Diagnose a plant image for diseases and pests using Plant.id Health Assessment API.
    func diagnose(image: UIImage, isPremium: Bool) async -> DiagnosisResult? {
        #if DEBUG
        print("🔬 DiagnosisService — diagnose called (isPremium: \(isPremium))")
        #endif

        guard canDiagnose(isPremium: isPremium) else {
            #if DEBUG
            print("🔬 DiagnosisService — BLOCKED: no credits")
            #endif
            return nil
        }

        guard cloudManager.isAPIKeyConfigured else {
            #if DEBUG
            print("🔬 DiagnosisService — BLOCKED: API key not configured")
            #endif
            return nil
        }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            #if DEBUG
            print("🔬 DiagnosisService — BLOCKED: could not compress image")
            #endif
            return nil
        }

        let base64Image = imageData.base64EncodedString()

        let requestBody: [String: Any] = [
            "images": ["data:image/jpeg;base64,\(base64Image)"],
            "similar_images": true,
            "disease_details": ["cause", "common_names", "classification", "description", "treatment"],
            "language": "en"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return nil
        }

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue(cloudManager.apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 30

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

            #if DEBUG
            print("🔬 DiagnosisService — response status: \(statusCode)")
            if let snippet = String(data: data.prefix(500), encoding: .utf8) {
                print("🔬 DiagnosisService — response snippet: \(snippet)")
            }
            #endif

            guard statusCode == 200 || statusCode == 201 else {
                #if DEBUG
                print("🔬 DiagnosisService — FAILED: status \(statusCode)")
                #endif
                return nil
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = json["result"] as? [String: Any] else {
                #if DEBUG
                print("🔬 DiagnosisService — FAILED: could not parse response")
                #endif
                return nil
            }

            // Parse health assessment
            var isHealthy = true
            var healthProbability = 1.0

            if let isHealthyResult = result["is_healthy"] as? [String: Any] {
                isHealthy = isHealthyResult["binary"] as? Bool ?? true
                healthProbability = isHealthyResult["probability"] as? Double ?? 1.0
            }

            // Parse disease suggestions
            var detectedIssues: [DiagnosisResult.DetectedIssue] = []

            if let disease = result["disease"] as? [String: Any],
               let suggestions = disease["suggestions"] as? [[String: Any]] {

                for suggestion in suggestions.prefix(5) {
                    let name = suggestion["name"] as? String ?? "Unknown"
                    let probability = suggestion["probability"] as? Double ?? 0

                    // Skip very low confidence results
                    guard probability > 0.05 else { continue }

                    var scientificName: String?
                    var description: String?
                    var treatment: DiagnosisResult.DetectedIssue.Treatment?
                    var commonNames: [String] = []
                    var category = "disease"

                    if let details = suggestion["details"] as? [String: Any] {
                        scientificName = details["scientific_name"] as? String

                        if let desc = details["description"] as? String {
                            description = desc
                        }

                        if let localName = details["common_names"] as? [String] {
                            commonNames = localName
                        }

                        // Parse classification for category
                        if let classification = details["classification"] as? [String: Any] {
                            if let cls = classification["kingdom"] as? String {
                                if cls.lowercased().contains("insect") || cls.lowercased().contains("animal") {
                                    category = "pest"
                                }
                            }
                        }

                        // Parse cause for category detection
                        if let cause = details["cause"] as? String {
                            let causeLower = cause.lowercased()
                            if causeLower.contains("insect") || causeLower.contains("mite") ||
                               causeLower.contains("pest") || causeLower.contains("bug") {
                                category = "pest"
                            } else if causeLower.contains("water") || causeLower.contains("light") ||
                                      causeLower.contains("nutrient") || causeLower.contains("temperature") {
                                category = "abiotic"
                            }
                        }

                        // Parse treatment
                        if let treatmentData = details["treatment"] as? [String: Any] {
                            let biological = treatmentData["biological"] as? [String] ?? []
                            let chemical = treatmentData["chemical"] as? [String] ?? []
                            let prevention = treatmentData["prevention"] as? [String] ?? []
                            treatment = DiagnosisResult.DetectedIssue.Treatment(
                                biological: biological,
                                chemical: chemical,
                                prevention: prevention
                            )
                        }
                    }

                    // Heuristic category from name if not set from details
                    let nameLower = name.lowercased()
                    if category == "disease" {
                        if nameLower.contains("mite") || nameLower.contains("aphid") ||
                           nameLower.contains("whitefly") || nameLower.contains("mealybug") ||
                           nameLower.contains("thrip") || nameLower.contains("scale") ||
                           nameLower.contains("caterpillar") || nameLower.contains("beetle") ||
                           nameLower.contains("fungus gnat") {
                            category = "pest"
                        } else if nameLower.contains("sunburn") || nameLower.contains("overwater") ||
                                  nameLower.contains("underwater") || nameLower.contains("nutrient") ||
                                  nameLower.contains("drought") || nameLower.contains("frost") {
                            category = "abiotic"
                        }
                    }

                    detectedIssues.append(DiagnosisResult.DetectedIssue(
                        name: name,
                        scientificName: scientificName,
                        probability: probability,
                        category: category,
                        description: description,
                        treatment: treatment,
                        commonNames: commonNames
                    ))
                }
            }

            // Decrement credits on success (free users only)
            if !isPremium {
                decrementCredits()
                #if DEBUG
                print("🔬 DiagnosisService — credits decremented -> \(creditsRemaining)")
                #endif
            }

            return DiagnosisResult(
                isHealthy: isHealthy,
                healthProbability: healthProbability,
                diseases: detectedIssues
            )

        } catch {
            #if DEBUG
            print("🔬 DiagnosisService — NETWORK ERROR: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    // MARK: - Severity Estimation

    /// Estimate severity based on probability and number of issues detected
    static func estimateSeverity(probability: Double, issueCount: Int) -> String {
        if probability > 0.85 && issueCount > 1 {
            return "critical"
        } else if probability > 0.7 {
            return "high"
        } else if probability > 0.4 {
            return "moderate"
        } else if probability > 0.15 {
            return "low"
        }
        return "none"
    }

    /// Create a DiagnosisEntry from a DiagnosisResult for persistence
    static func createEntry(
        from result: DiagnosisResult,
        issue: DiagnosisResult.DetectedIssue?,
        imageData: Data?,
        plant: Plant?
    ) -> DiagnosisEntry {
        let entry = DiagnosisEntry(
            isHealthy: result.isHealthy,
            diseaseName: issue?.name,
            scientificName: issue?.scientificName,
            category: issue?.category ?? (result.isHealthy ? "healthy" : "unknown"),
            confidence: issue?.probability ?? result.healthProbability,
            severity: issue != nil ? estimateSeverity(
                probability: issue!.probability,
                issueCount: result.diseases.count
            ) : "none",
            photoData: imageData,
            plant: plant
        )

        entry.descriptionText = issue?.description

        if let treatment = issue?.treatment {
            let allSteps = treatment.biological + treatment.chemical
            if let stepsData = try? JSONEncoder().encode(allSteps) {
                entry.treatmentSteps = String(data: stepsData, encoding: .utf8)
            }
            if let preventionData = try? JSONEncoder().encode(treatment.prevention) {
                entry.preventionTips = String(data: preventionData, encoding: .utf8)
            }
        }

        if let names = issue?.commonNames, !names.isEmpty {
            entry.commonNames = names.joined(separator: ", ")
        }

        return entry
    }
}
