import UIKit
import Vision
import CoreML

/// On-device AI plant identification using a dedicated houseplant CoreML model (ViT-Base)
/// Identifies 47 common houseplant species with ~90% accuracy
/// Runs fully offline — no network, no API keys, no data collection
final class PlantIdentifierService {
    static let shared = PlantIdentifierService()

    private var vnModel: VNCoreMLModel?

    private init() {
        loadModel()
    }

    struct IdentificationResult {
        let species: String?
        let confidence: Double       // 0.0–1.0
        let defaultInterval: Int     // Suggested watering days
        let isLowConfidence: Bool    // True if confidence < 0.70
    }

    // MARK: - Model Loading

    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndNeuralEngine
            let model = try HousePlantIdentifier(configuration: config)
            vnModel = try VNCoreMLModel(for: model.model)
            print("HousePlantIdentifier CoreML model loaded successfully")
        } catch {
            print("Failed to load HousePlantIdentifier model: \(error)")
            // Fallback: will use Vision classifier
        }
    }

    // MARK: - Identification

    /// Identify a plant from a UIImage using the on-device CoreML model
    func identifyPlant(from image: UIImage) async -> IdentificationResult {
        guard let cgImage = image.cgImage else {
            return IdentificationResult(species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true)
        }

        // Use CoreML model if available, otherwise fall back to Vision classifier
        if let vnModel = vnModel {
            return await identifyWithCoreML(cgImage: cgImage, model: vnModel)
        } else {
            return await identifyWithVision(cgImage: cgImage)
        }
    }

    // MARK: - CoreML Path (primary — 47 houseplant species, ~90% accuracy)

    private func identifyWithCoreML(cgImage: CGImage, model: VNCoreMLModel) async -> IdentificationResult {
        return await withCheckedContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation],
                      let top = results.first else {
                    continuation.resume(returning: IdentificationResult(
                        species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true
                    ))
                    return
                }

                let confidence = Double(top.confidence)
                let rawLabel = top.identifier

                // Map CoreML label to our app's species database
                let mapped = Self.mapToAppSpecies(rawLabel)
                let interval = PlantSpeciesDatabase.species(named: mapped)?.defaultWateringDays ?? Self.defaultInterval(for: rawLabel)

                continuation.resume(returning: IdentificationResult(
                    species: mapped,
                    confidence: confidence,
                    defaultInterval: interval,
                    isLowConfidence: confidence < 0.70
                ))
            }

            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("CoreML request failed: \(error)")
                continuation.resume(returning: IdentificationResult(
                    species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true
                ))
            }
        }
    }

    // MARK: - Vision Fallback (generic classifier)

    private func identifyWithVision(cgImage: CGImage) async -> IdentificationResult {
        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: IdentificationResult(
                        species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true
                    ))
                    return
                }

                let result = Self.matchVisionSpecies(from: observations)
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

    // MARK: - Species Mapping

    /// Map CoreML model output labels to our PlantSpeciesDatabase names
    private static func mapToAppSpecies(_ label: String) -> String {
        // The CoreML model returns labels like "Monstera Deliciosa (Monstera deliciosa)"
        // Map these to our PlantSpeciesDatabase names where possible
        let mapping: [String: String] = [
            "African Violet (Saintpaulia ionantha)": "Saintpaulia - African Violet",
            "Aloe Vera": "Aloe Vera",
            "Anthurium (Anthurium andraeanum)": "Anthurium",
            "Areca Palm (Dypsis lutescens)": "Areca Palm",
            "Asparagus Fern (Asparagus setaceus)": "Boston Fern",
            "Begonia (Begonia spp.)": "Begonia",
            "Bird of Paradise (Strelitzia reginae)": "Bird of Paradise",
            "Birds Nest Fern (Asplenium nidus)": "Boston Fern",
            "Boston Fern (Nephrolepis exaltata)": "Boston Fern",
            "Calathea": "Calathea",
            "Cast Iron Plant (Aspidistra elatior)": "Cast Iron Plant",
            "Chinese Money Plant (Pilea peperomioides)": "Chinese Money Plant",
            "Chinese evergreen (Aglaonema)": "Aglaonema - Chinese Evergreen",
            "Christmas Cactus (Schlumbergera bridgesii)": "Christmas Cactus",
            "Chrysanthemum": "Chrysanthemum",
            "Ctenanthe": "Calathea",
            "Daffodils (Narcissus spp.)": "Daffodil",
            "Dracaena": "Dracaena",
            "Dumb Cane (Dieffenbachia spp.)": "Dieffenbachia",
            "Elephant Ear (Alocasia spp.)": "Alocasia - Elephant Ear",
            "English Ivy (Hedera helix)": "Hedera - Ivy",
            "Hyacinth (Hyacinthus orientalis)": "Hyacinth",
            "Iron Cross begonia (Begonia masoniana)": "Begonia",
            "Jade plant (Crassula ovata)": "Crassula - Jade Plant",
            "Kalanchoe": "Kalanchoe",
            "Lilium (Hemerocallis)": "Lilium - Lily",
            "Lily of the valley (Convallaria majalis)": "Lilium - Lily",
            "Money Tree (Pachira aquatica)": "Money Tree",
            "Monstera Deliciosa (Monstera deliciosa)": "Monstera Deliciosa",
            "Orchid": "Orchid - Phalaenopsis",
            "Parlor Palm (Chamaedorea elegans)": "Parlor Palm",
            "Peace lily": "Peace Lily",
            "Poinsettia (Euphorbia pulcherrima)": "Poinsettia",
            "Polka Dot Plant (Hypoestes phyllostachya)": "Polka Dot Plant",
            "Ponytail Palm (Beaucarnea recurvata)": "Ponytail Palm",
            "Pothos (Ivy arum)": "Epipremnum - Pothos",
            "Prayer Plant (Maranta leuconeura)": "Prayer Plant",
            "Rattlesnake Plant (Calathea lancifolia)": "Calathea",
            "Rubber Plant (Ficus elastica)": "Ficus Elastica - Rubber Plant",
            "Sago Palm (Cycas revoluta)": "Sago Palm",
            "Schefflera": "Schefflera",
            "Snake plant (Sanseviera)": "Sansevieria - Snake Plant",
            "Tradescantia": "Tradescantia",
            "Tulip": "Tulip",
            "Venus Flytrap": "Venus Flytrap",
            "Yucca": "Yucca",
            "ZZ Plant (Zamioculcas zamiifolia)": "Zamioculcas - ZZ Plant",
        ]

        return mapping[label] ?? label
    }

    /// Default watering interval for species not in our database
    private static func defaultInterval(for label: String) -> Int {
        let lowered = label.lowercased()
        if lowered.contains("cactus") || lowered.contains("succulent") || lowered.contains("aloe") || lowered.contains("jade") || lowered.contains("zz plant") {
            return 14
        } else if lowered.contains("fern") || lowered.contains("calathea") || lowered.contains("prayer") {
            return 3
        } else if lowered.contains("palm") || lowered.contains("monstera") || lowered.contains("pothos") {
            return 7
        }
        return 7
    }

    // MARK: - Vision Fallback Matching

    /// Match Vision classifier observations to plant species (fallback only)
    private static let visionKeywords: [String: String] = [
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
        "aloe": "Aloe Vera",
        "ivy": "Hedera - Ivy",
        "philodendron": "Philodendron",
        "calathea": "Calathea",
        "peace lily": "Peace Lily",
        "spider plant": "Chlorophytum - Spider Plant",
        "jade": "Crassula - Jade Plant",
        "begonia": "Begonia",
        "dracaena": "Dracaena",
        "yucca": "Yucca",
    ]

    private static func matchVisionSpecies(from observations: [VNClassificationObservation]) -> IdentificationResult {
        let topObservations = observations.prefix(20)

        for observation in topObservations {
            let label = observation.identifier.lowercased()
            let confidence = Double(observation.confidence)

            for (keyword, speciesName) in visionKeywords {
                if label.contains(keyword) {
                    let dbSpecies = PlantSpeciesDatabase.species(named: speciesName)
                    return IdentificationResult(
                        species: speciesName,
                        confidence: min(confidence * 1.2, 1.0),
                        defaultInterval: dbSpecies?.defaultWateringDays ?? 7,
                        isLowConfidence: confidence < 0.50
                    )
                }
            }
        }

        // Check if it's a plant at all
        let plantKeywords = ["plant", "flower", "leaf", "botanical", "garden", "houseplant",
                             "floral", "vegetation", "foliage", "petal", "stem", "pot"]
        for observation in topObservations {
            let label = observation.identifier.lowercased()
            if plantKeywords.contains(where: { label.contains($0) }) {
                return IdentificationResult(
                    species: nil,
                    confidence: Double(observation.confidence) * 0.5,
                    defaultInterval: 7,
                    isLowConfidence: true
                )
            }
        }

        return IdentificationResult(species: nil, confidence: 0, defaultInterval: 7, isLowConfidence: true)
    }
}
