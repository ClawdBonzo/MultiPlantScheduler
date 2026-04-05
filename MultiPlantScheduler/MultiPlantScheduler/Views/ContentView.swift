import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var showOnboarding: Bool
    @State private var launchAddPlant = false
    @State private var showCelebratory = false
    @State private var selectedTab: Tab = .garden

    enum Tab: String {
        case garden, diagnose, community, analytics, settings
    }

    init() {
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let legacy = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        _showOnboarding = State(initialValue: !(completed || legacy))

        // Premium dark tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.045, green: 0.048, blue: 0.048, alpha: 1)
        appearance.shadowColor = .clear

        // Unselected items — muted
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.35, alpha: 1)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.35, alpha: 1),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        // Selected items — emerald glow
        let selectedColor = UIColor(red: 0.15, green: 0.78, blue: 0.42, alpha: 1)
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    DashboardView()
                }
                .tag(Tab.garden)
                .tabItem {
                    Label("Garden", systemImage: "leaf.fill")
                }

                DiagnoseTabView()
                    .tag(Tab.diagnose)
                    .tabItem {
                        Label("Diagnose", systemImage: "microbe.fill")
                    }

                CommunityTabView()
                    .tag(Tab.community)
                    .tabItem {
                        Label("Community", systemImage: "person.2.fill")
                    }

                AnalyticsTabView()
                    .tag(Tab.analytics)
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.fill")
                    }

                NavigationStack {
                    SettingsView()
                }
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .tint(AppColors.emerald)

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
