import SwiftUI
import SwiftData
import WidgetKit

@main
struct MultiPlantSchedulerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var showOnboarding: Bool
    @State private var showSoftPaywall = false
    @Environment(\.scenePhase) private var scenePhase

    let modelContainer: ModelContainer

    init() {
        // Configure SwiftData container using default store location
        var container: ModelContainer

        do {
            container = try SharedContainer.makeModelContainer()
        } catch {
            print("⚠️ Container failed: \(error). Using in-memory store.")
            // In-memory fallback — app works but data won't persist
            let schema = SharedContainer.schema
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            do {
                container = try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                // This should never happen, but if it does, create the simplest possible container
                print("❌ In-memory store also failed: \(error)")
                container = try! ModelContainer(for: Plant.self, CareLog.self)
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
                                // Show soft paywall after onboarding completes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showSoftPaywall = true
                                }
                            }
                        }
                } else {
                    ContentView()
                }
            }
            .sheet(isPresented: $showSoftPaywall) {
                SoftPaywallView()
                    .environmentObject(revenueCatManager)
            }
            .modelContainer(modelContainer)
            .environmentObject(revenueCatManager)
            .preferredColorScheme(.dark)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    // Clear badge count when app becomes active
                    NotificationManager.shared.clearBadgeCount()
                    // Refresh widgets
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }
}
