import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var showOnboarding: Bool
    @State private var launchAddPlant = false
    @State private var showCelebratory = false

    init() {
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        // Also check legacy key for existing users
        let legacy = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        _showOnboarding = State(initialValue: !(completed || legacy))
    }

    var body: some View {
        ZStack {
            NavigationStack {
                DashboardView()
            }

            if showOnboarding {
                OnboardingView(
                    isPresented: $showOnboarding,
                    launchAddPlant: $launchAddPlant
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .sheet(isPresented: $launchAddPlant) {
            AddPlantView(isFromOnboarding: true, openCameraOnAppear: true, showCelebratory: $showCelebratory)
                .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showCelebratory) {
            CelebratoryView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(RevenueCatManager.shared)
}
