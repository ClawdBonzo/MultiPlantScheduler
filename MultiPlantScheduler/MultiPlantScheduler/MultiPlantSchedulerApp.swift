import SwiftUI
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.clawdbonzo.MultiPlantScheduler", category: "AppLaunch")

@main
struct MultiPlantSchedulerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var hasAppeared = false
    @Environment(\.scenePhase) private var scenePhase

    let modelContainer: ModelContainer

    init() {
        logger.notice("App init starting")

        // Configure SwiftData container
        let schema = Schema([Plant.self, CareLog.self, HealthEntry.self, PhotoEntry.self])
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

        // Mark first launch (no sample seeding)
        if FirstLaunchService.isFirstLaunch {
            FirstLaunchService.markLaunchComplete()
        }

        logger.notice("App init complete")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
