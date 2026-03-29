import SwiftUI
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.clawdbonzo.MultiPlantScheduler", category: "AppLaunch")

@main
struct MultiPlantSchedulerApp: App {
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var showOnboarding: Bool
    @State private var showSoftPaywall = false
    @State private var hasAppeared = false
    @Environment(\.scenePhase) private var scenePhase

    let modelContainer: ModelContainer

    init() {
        logger.notice("App init starting")

        let schema = Schema([Plant.self, CareLog.self])
        var container: ModelContainer

        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
            container = try ModelContainer(for: schema, configurations: config)
            logger.notice("Persistent ModelContainer created")
        } catch {
            logger.error("Persistent store failed: \(error.localizedDescription). Using in-memory.")
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try! ModelContainer(for: schema, configurations: config)
        }

        self.modelContainer = container

        if FirstLaunchService.isFirstLaunch {
            FirstLaunchService.seedSamplePlants(context: container.mainContext)
            FirstLaunchService.markLaunchComplete()
        }

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        _showOnboarding = State(initialValue: !hasSeenOnboarding)

        logger.notice("App init complete")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView(isPresented: $showOnboarding)
                        .onChange(of: showOnboarding) { _, newValue in
                            if !newValue {
                                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
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
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                logger.notice("App body appeared — configuring RevenueCat")
                revenueCatManager.configure()
                Task {
                    let _ = await NotificationManager.shared.requestPermission()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    NotificationManager.shared.clearBadgeCount()
                }
            }
        }
    }
}
