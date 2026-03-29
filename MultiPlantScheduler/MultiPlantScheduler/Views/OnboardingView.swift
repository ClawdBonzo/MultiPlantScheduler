import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button (only on pages 0-1)
                HStack {
                    if currentPage < 2 {
                        Button(action: { currentPage = 2 }) {
                            Text("Skip")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // TabView for pages
                TabView(selection: $currentPage) {
                    // Page 1
                    OnboardingPage(
                        title: "Welcome to MultiPlant AI",
                        subtitle: "Track 30+ plants in one place",
                        icon: "leaf.fill",
                        iconColor: AppColors.limeGreen,
                        content: {
                            HStack(spacing: 20) {
                                ForEach(
                                    [("leaf.fill", Color.green), ("camera.viewfinder", Color.blue),
                                     ("drop.fill", Color.cyan), ("sun.max.fill", Color.yellow)],
                                    id: \.0
                                ) { icon, color in
                                    Image(systemName: icon)
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundStyle(color)
                                        .frame(width: 56, height: 56)
                                        .background(color.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .padding(.vertical, 20)
                        }
                    )
                    .tag(0)

                    // Page 2
                    OnboardingPage(
                        title: "Never Forget to Water",
                        subtitle: "Smart reminders that adjust by season",
                        icon: "bell.badge.fill",
                        iconColor: AppColors.limeGreen,
                        content: {
                            VStack(spacing: 12) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 44, weight: .semibold))
                                    .foregroundColor(AppColors.limeGreen)

                                Text("Get notified when your plants need attention")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 20)
                        }
                    )
                    .tag(1)

                    // Page 3
                    OnboardingPage(
                        title: "Your Garden Awaits",
                        subtitle: "Let's get started!",
                        icon: "sparkles",
                        iconColor: .yellow,
                        content: {
                            VStack(spacing: 16) {
                                Button(action: { isPresented = false }) {
                                    Text("Get Started")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.background)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(AppColors.limeGreen)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 10)

                                Button(action: { isPresented = false }) {
                                    Text("Maybe Later")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.limeGreen)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(AppColors.forestGreen.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.vertical, 20)
                        }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppColors.limeGreen : AppColors.textSecondary.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                Spacer()
            }
        }
    }
}

struct OnboardingPage<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(iconColor)

                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            content()

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    @State var isPresented = true

    return OnboardingView(isPresented: $isPresented)
}
