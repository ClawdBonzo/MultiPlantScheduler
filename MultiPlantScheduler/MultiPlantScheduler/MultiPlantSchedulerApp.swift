import SwiftUI
import SwiftData
import WidgetKit
import os.log

private let logger = Logger(subsystem: "com.clawdbonzo.MultiPlantScheduler", category: "AppLaunch")

@main
struct MultiPlantSchedulerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @State private var showOnboarding: Bool
    @State private var showSoftPaywall = false
    @State private var hasAppeared = false
    @Environment(\.scenePhase) private var scenePhase

    let modelContainer: ModelContainer

    init() {
        logger.notice("App init starting")

        // Configure SwiftData container
        let container = Self.createModelContainer()
        self.modelContainer = container
        logger.notice("ModelContainer created successfully")

        // Seed sample data on first launch
        if FirstLaunchService.isFirstLaunch {
            FirstLaunchService.seedSamplePlants(context: container.mainContext)
            FirstLaunchService.markLaunchComplete()
        }

        // Show onboarding if this is the first launch
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        _showOnboarding = State(initialValue: !hasSeenOnboarding)

        logger.notice("App init complete")
    }

    /// Create a ModelContainer with aggressive fallback chain
    private static func createModelContainer() -> ModelContainer {
        // Attempt 1: Open existing store with full schema
        do {
            return try SharedContainer.makeModelContainer()
        } catch {
            print("⚠️ Container failed: \(error)")
        }

        // Attempt 2: Delete corrupt store and retry
        do {
            let storeURL = URL.applicationSupportDirectory.appendingPathComponent("default.store")
            for ext in ["", "-shm", "-wal"] {
                let fileURL = storeURL.appendingPathExtension(ext.isEmpty ? "" : String(ext.dropFirst()))
                let url = ext.isEmpty ? storeURL : URL(fileURLWithPath: storeURL.path + ext)
                try? FileManager.default.removeItem(at: url)
            }
            print("🗑️ Deleted old store, creating fresh one...")
            return try SharedContainer.makeModelContainer()
        } catch {
            print("⚠️ Fresh store failed: \(error)")
        }

        // Attempt 3: In-memory store (app works but data won't persist)
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            return try ModelContainer(for: SharedContainer.schema, configurations: config)
        } catch {
            print("❌ In-memory store failed: \(error)")
        }

        // Attempt 4: Absolute minimum — just Plant and CareLog, in memory
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Plant.self, CareLog.self, configurations: config)
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
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                logger.notice("App body appeared — configuring RevenueCat")
                // Configure RevenueCat after UI is loaded to avoid init crash
                revenueCatManager.configure()
                // Request notification permission
                Task {
                    let _ = await NotificationManager.shared.requestPermission()
                }
            }
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
