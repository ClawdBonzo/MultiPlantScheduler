import SwiftUI
import SwiftData

@main
struct MultiPlantSchedulerApp: App {
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var showOnboarding: Bool

    let modelContainer: ModelContainer

    init() {
        // Configure SwiftData container
        let schema = Schema([Plant.self, CareLog.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContainer = container

            // Seed sample data on first launch (before onboarding shows)
            if FirstLaunchService.isFirstLaunch {
                FirstLaunchService.seedSamplePlants(context: container.mainContext)
                FirstLaunchService.markLaunchComplete()
            }
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }

        // Show onboarding if this is the first launch (check before markComplete resets it)
        // We use a separate UserDefaults key for onboarding
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        _showOnboarding = State(initialValue: !hasSeenOnboarding)

        // Request notification permissions
        Task {
            let _ = await NotificationManager.shared.requestPermission()
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView(isPresented: $showOnboarding)
                        .onChange(of: showOnboarding) { _, newValue in
                            if !newValue {
                                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                            }
                        }
                } else {
                    ContentView()
                }
            }
            .modelContainer(modelContainer)
            .environmentObject(revenueCatManager)
            .preferredColorScheme(.dark)
        }
    }
}
