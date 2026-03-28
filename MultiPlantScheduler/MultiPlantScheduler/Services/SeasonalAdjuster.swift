import Foundation

/// Adjusts watering intervals based on the season
enum SeasonalAdjuster {
    /// Seasons for adjustment
    enum Season {
        case spring   // Mar-May: +1 day
        case summer   // Jun-Aug: no adjustment
        case fall     // Sep-Nov: +1 day
        case winter   // Dec-Feb: +3 days

        var displayName: String {
            switch self {
            case .spring:
                return "Spring"
            case .summer:
                return "Summer"
            case .fall:
                return "Fall"
            case .winter:
                return "Winter"
            }
        }
    }

    /// Get the current season based on the provided date
    /// - Parameter date: The date to determine the season for (defaults to now)
    /// - Returns: The current Season
    static func currentSeason(for date: Date = .now) -> Season {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 3...5:
            return .spring
        case 6...8:
            return .summer
        case 9...11:
            return .fall
        default:  // 12, 1, 2
            return .winter
        }
    }

    /// Get the adjustment amount in days for the given season
    /// - Parameter season: The season to get adjustment for
    /// - Returns: The number of days to add to the base interval
    static func adjustment(for season: Season) -> Int {
        switch season {
        case .spring:
            return 1
        case .summer:
            return 0
        case .fall:
            return 1
        case .winter:
            return 3
        }
    }

    /// Calculate the adjusted watering interval based on season
    /// - Parameters:
    ///   - baseInterval: The base watering interval in days
    ///   - date: The date to calculate the season for (defaults to now)
    /// - Returns: The adjusted interval (never less than 1 day)
    static func adjustedInterval(baseInterval: Int, for date: Date = .now) -> Int {
        let season = currentSeason(for: date)
        let adjustmentDays = adjustment(for: season)
        let adjusted = baseInterval + adjustmentDays
        return max(adjusted, Constants.App.minimumWateringInterval)
    }

    /// Get the name of the current season
    /// - Parameter date: The date to determine the season for (defaults to now)
    /// - Returns: The display name of the current season
    static func currentSeasonName(for date: Date = .now) -> String {
        currentSeason(for: date).displayName
    }
}
