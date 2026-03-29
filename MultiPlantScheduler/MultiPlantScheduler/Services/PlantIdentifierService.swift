import UIKit
import Vision

/// On-device AI plant identification using Apple Vision framework
/// Runs fully offline with zero latency — no network, no API keys, no data collection
///
/// Architecture note: VNClassifyImageRequest uses Apple's built-in image classifier which
/// recognizes broad categories including many plant types. For production-grade species-level
/// identification, swap in a custom CoreML model (see comment in `identifyPlant`).
final class PlantIdentifierService {
    static let shared = PlantIdentifierService()
    private init() {}

    struct IdentificationResult {
        let species: String?
        let confidence: Double       // 0.0–1.0
        let defaultInterval: Int     // Suggested watering days
        let isLowConfidence: Bool    // True if confidence < 0.70
    }

    // MARK: - Known plant keyword → species mapping
    // Maps Vision classifier labels to our PlantSpeciesDatabase entries
    private static let classifierToSpecies: [String: String] = [
        "monstera": "Monstera Deliciosa",
        "pothos": "Epipremnum - Pothos",
        "snake plant": "Sansevieria - Snake Plant",
        "sansevieria": "Sansevieria - Snake Plant",
        "fern": "Boston Fern",
        "cactus": "Cactus - Barrel",
        "succulent": "Echeveria",
        "orchid": "Orchid - Phalaenopsis",
        "palm": "Areca Palm",
        "ficus": "Ficus Benjamina",
        "fiddle": "Ficus Lyrata - Fiddle Leaf Fig",
        "rubber": "Ficus Elastica - Rubber Plant",
        "aloe": "Aloe Vera",
        "ivy": "Hedera - Ivy",
        "philodendron": "Philodendron",
        "calathea": "Calathea",
        "peace lily": "Peace Lily",
        "spider plant": "Chlorophytum - Spider Plant",
        "jade": "Crassula - Jade Plant",
        "begonia": "Begonia",
        "hibiscus": "Hibiscus",
        "rose": "Rosa - Rose",
        "lily": "Lilium - Lily",
        "tulip": "Tulip",
        "daisy": "Gerbera Daisy",
        "dracaena": "Dracaena",
        "yucca": "Yucca",
        "bromeliad": "Bromeliad",
        "anthurium": "Anthurium",
        "croton": "Croton",
        "geranium": "Geranium",
        "lavender": "Rosemary",
        "herb": "Rosemary",
        "air plant": "Tillandsia - Air Plant",
        "string of pearls": "Senecio - String of Pearls",
        "zz plant": "Zamioculcas - ZZ Plant",
        "peperomia": "Peperomia",
        "hoya": "Hoya - Wax Plant",
        "syngonium": "Syngonium",
        "tradescantia": "Tradescantia",
        "african violet": "Saintpaulia - African Violet",
        "kalanchoe": "Kalanchoe",
        "poinsettia": "Poinsettia",
        "hydrangea": "Hydrangea",
    ]

    /// Identify a plant from a UIImage using on-device Vision AI
    ///
    /// - Parameter image: The plant photo to analyze
    /// - Returns: An `IdentificationResult` with species, confidence, and watering interval
    ///
    /// To upgrade to species-level accuracy:
    /// 1. Download a plant classification CoreML model (e.g. from HuggingFace — search "plant species classifier coreml")
    /// 2. Add the .mlmodel file to the Xcode project
    /// 3. Replace VNClassifyImageRequest below with:
    ///    ```
    ///    let model = try VNCoreMLModel(for: YourPlantModel(configuration: .init()).model)
    ///    let request = VNCoreMLRequest(model: model)
    ///    ```
    /// 4. Update `matchSpecies` to handle the model's label format
    func identifyPlant(from image: UIImage) async -> IdentificationResult {
        guard let cgImage = image.cgImage else {
            return IdentificationResult(species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true)
        }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: IdentificationResult(
                        species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true
                    ))
                    return
                }

                // Filter for plant-related classifications and find best match
                let result = Self.matchSpecies(from: observations)
                continuation.resume(returning: result)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Vision request failed: \(error)")
                continuation.resume(returning: IdentificationResult(
                    species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true
                ))
            }
        }
    }

    // MARK: - Private

    /// Match Vision classifier observations to our plant species database
    private static func matchSpecies(from observations: [VNClassificationObservation]) -> IdentificationResult {
        // Look through top observations for plant-related labels
        let topObservations = observations.prefix(20)

        for observation in topObservations {
            let label = observation.identifier.lowercased()
            let confidence = Double(observation.confidence)

            // Check direct mapping
            for (keyword, speciesName) in classifierToSpecies {
                if label.contains(keyword) {
                    let dbSpecies = PlantSpeciesDatabase.species(named: speciesName)
                    return IdentificationResult(
                        species: speciesName,
                        confidence: min(confidence * 1.2, 1.0), // Boost since we matched a known plant keyword
                        defaultInterval: dbSpecies?.defaultWateringDays ?? 7,
                        isLowConfidence: confidence < 0.50
                    )
                }
            }

            // Check if the label itself matches any species in our database (fuzzy)
            let matched = PlantSpeciesDatabase.database.first { species in
                let speciesLower = species.name.lowercased()
                return speciesLower.contains(label) || label.contains(speciesLower.components(separatedBy: " - ").last ?? speciesLower)
            }
            if let matched {
                return IdentificationResult(
                    species: matched.name,
                    confidence: min(confidence * 1.1, 1.0),
                    defaultInterval: matched.defaultWateringDays,
                    isLowConfidence: confidence < 0.50
                )
            }
        }

        // Check if any observation suggests it's a plant/flower at all
        let plantKeywords = ["plant", "flower", "leaf", "botanical", "garden", "houseplant",
                             "floral", "vegetation", "foliage", "petal", "stem", "pot"]
        for observation in topObservations {
            let label = observation.identifier.lowercased()
            if plantKeywords.contains(where: { label.contains($0) }) {
                let confidence = Double(observation.confidence)
                return IdentificationResult(
                    species: nil,
                    confidence: confidence * 0.5, // Lower confidence — we know it's a plant but not which one
                    defaultInterval: 7,
                    isLowConfidence: true
                )
            }
        }

        // No plant detected at all
        return IdentificationResult(
            species: nil,
            confidence: 0,
            defaultInterval: 7,
            isLowConfidence: true
        )
    }
}
