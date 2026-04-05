import SwiftData
import SwiftUI
import Foundation

/// A disease or pest diagnosis result for a plant
@Model
final class DiagnosisEntry {
    var id: UUID = UUID()
    var diagnosisDate: Date = Date.now
    var photoData: Data?  // The image that was analyzed

    // Diagnosis results
    var isHealthy: Bool = true
    var diseaseName: String?        // e.g. "Powdery Mildew", "Spider Mites"
    var scientificName: String?     // e.g. "Erysiphales"
    var category: String = "unknown" // "disease", "pest", "abiotic", "healthy"
    var confidence: Double = 0.0    // 0.0–1.0
    var severity: String = "none"   // "none", "low", "moderate", "high", "critical"

    // Treatment info
    var treatmentSummary: String?   // Brief treatment description
    var treatmentSteps: String?     // JSON-encoded array of treatment steps
    var preventionTips: String?     // JSON-encoded array of prevention tips

    // Additional details
    var descriptionText: String?    // Full description of the issue
    var commonNames: String?        // Other common names for the disease/pest

    // Link to plant (optional — can diagnose without linking)
    var plant: Plant?

    init(
        isHealthy: Bool = true,
        diseaseName: String? = nil,
        scientificName: String? = nil,
        category: String = "unknown",
        confidence: Double = 0.0,
        severity: String = "none",
        photoData: Data? = nil,
        plant: Plant? = nil
    ) {
        self.id = UUID()
        self.diagnosisDate = Date.now
        self.isHealthy = isHealthy
        self.diseaseName = diseaseName
        self.scientificName = scientificName
        self.category = category
        self.confidence = confidence
        self.severity = severity
        self.photoData = photoData
        self.plant = plant
    }

    // MARK: - Computed Properties

    var severityLevel: SeverityLevel {
        SeverityLevel(rawValue: severity) ?? .none
    }

    var diagnosisCategory: DiagnosisCategory {
        DiagnosisCategory(rawValue: category) ?? .unknown
    }

    var photoImage: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else { return nil }
        return Image(uiImage: uiImage)
    }

    /// Decode treatment steps from JSON string
    var decodedTreatmentSteps: [String] {
        guard let data = treatmentSteps?.data(using: .utf8),
              let steps = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return steps
    }

    /// Decode prevention tips from JSON string
    var decodedPreventionTips: [String] {
        guard let data = preventionTips?.data(using: .utf8),
              let tips = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return tips
    }
}

// MARK: - Enums

enum SeverityLevel: String, CaseIterable {
    case none, low, moderate, high, critical

    var displayName: String {
        switch self {
        case .none: return "Healthy"
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    var color: Color {
        switch self {
        case .none: return Constants.Colors.forestGreen
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return Color(red: 1.0, green: 0.3, blue: 0.2)
        case .critical: return .red
        }
    }

    var emoji: String {
        switch self {
        case .none: return "✅"
        case .low: return "⚠️"
        case .moderate: return "🟠"
        case .high: return "🔴"
        case .critical: return "🚨"
        }
    }

    var iconName: String {
        switch self {
        case .none: return "checkmark.shield.fill"
        case .low: return "exclamationmark.triangle"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "xmark.octagon"
        case .critical: return "xmark.octagon.fill"
        }
    }
}

enum DiagnosisCategory: String, CaseIterable {
    case disease, pest, abiotic, healthy, unknown

    var displayName: String {
        switch self {
        case .disease: return "Disease"
        case .pest: return "Pest"
        case .abiotic: return "Environmental"
        case .healthy: return "Healthy"
        case .unknown: return "Unknown"
        }
    }

    var emoji: String {
        switch self {
        case .disease: return "🦠"
        case .pest: return "🐛"
        case .abiotic: return "🌡️"
        case .healthy: return "💚"
        case .unknown: return "❓"
        }
    }

    var iconName: String {
        switch self {
        case .disease: return "allergens"
        case .pest: return "ant.fill"
        case .abiotic: return "thermometer.sun.fill"
        case .healthy: return "leaf.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .disease: return .purple
        case .pest: return .orange
        case .abiotic: return .yellow
        case .healthy: return Constants.Colors.forestGreen
        case .unknown: return .gray
        }
    }
}
