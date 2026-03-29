import SwiftUI

/// Health status options for tracking plant wellbeing
enum HealthStatus: String, CaseIterable, Codable {
    case healthy = "healthy"
    case okay = "okay"
    case struggling = "struggling"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .okay: return "Okay"
        case .struggling: return "Struggling"
        case .unknown: return "Unknown"
        }
    }

    var emoji: String {
        switch self {
        case .healthy: return "🌿"
        case .okay: return "🌱"
        case .struggling: return "🍂"
        case .unknown: return "❓"
        }
    }

    var color: Color {
        switch self {
        case .healthy: return .green
        case .okay: return .yellow
        case .struggling: return .red
        case .unknown: return .gray
        }
    }

    var iconName: String {
        switch self {
        case .healthy: return "heart.fill"
        case .okay: return "heart"
        case .struggling: return "heart.slash"
        case .unknown: return "questionmark.circle"
        }
    }
}
