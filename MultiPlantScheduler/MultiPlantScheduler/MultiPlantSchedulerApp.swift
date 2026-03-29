import SwiftUI
import SwiftData

@main
struct MultiPlantSchedulerApp: App {
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var showOnboarding: Bool

    let modelContainer: ModelContainer

    init() {
        // Configure SwiftData container with fallback to in-memory if persistent store fails
        let schema = Schema([Plant.self, CareLog.self])
        var container: ModelContainer

        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("⚠️ Persistent store failed: \(error). Falling back to in-memory store.")
            do {
                let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                container = try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                // Last resort — this should never fail, but guard against it
                print("❌ Even in-memory store failed: \(error)")
                container = try! ModelContainer(for: schema)
            }
        }

        self.modelContainer = container

        // Seed sample data on first launch
        if FirstLaunchService.isFirstLaunch {
            FirstLaunchService.seedSamplePlants(context: container.mainContext)
            FirstLaunchService.markLaunchComplete()
        }

        // Show onboarding if this is the first launch
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        _showOnboarding = State(initialValue: !hasSeenOnboarding)

        // Delay notification permission request until app is fully launched
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Task {
                let _ = await NotificationManager.shared.requestPermission()
            }
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
