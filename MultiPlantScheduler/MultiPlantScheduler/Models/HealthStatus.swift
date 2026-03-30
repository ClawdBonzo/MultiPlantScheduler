import SwiftUI

/// Health status options for tracking plant wellbeing
enum HealthStatus: String, CaseIterable, Codable {
    case healthy = "healthy"
    case okay = "okay"
    case struggling = "struggling"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .healthy: return NSLocalizedString("Healthy", comment: "Health status: healthy")
        case .okay: return NSLocalizedString("Okay", comment: "Health status: okay")
        case .struggling: return NSLocalizedString("Struggling", comment: "Health status: struggling")
        case .unknown: return NSLocalizedString("Unknown", comment: "Health status: unknown")
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
