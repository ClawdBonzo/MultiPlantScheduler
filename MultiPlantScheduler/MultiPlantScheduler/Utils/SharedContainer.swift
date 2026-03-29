import Foundation
import SwiftData

/// Centralized App Group container configuration for sharing data between app and extensions
enum SharedContainer {
    static let appGroupID = "group.com.clawdbonzo.MultiPlantScheduler"

    /// The full SwiftData schema for the app
    static var schema: Schema {
        Schema([Plant.self, CareLog.self, HealthEntry.self, PhotoEntry.self])
    }

    /// Create a ModelContainer using the default store location
    /// Uses the standard SwiftData path to preserve existing user data
    static func makeModelContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }
}
