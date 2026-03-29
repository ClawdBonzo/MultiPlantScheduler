import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @Binding var launchAddPlant: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    // MARK: - Page 1: Hook
                    VStack(spacing: 32) {
                        Spacer()

                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 80, weight: .light))
                            .foregroundStyle(AppColors.limeGreen)

                        VStack(spacing: 12) {
                            Text("Identify Any Houseplant Instantly")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Snap a photo. AI tells you what it is\nand when to water it.")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        // Benefit pills
                        HStack(spacing: 12) {
                            BenefitPill(icon: "camera.viewfinder", label: "AI Plant ID")
                            BenefitPill(icon: "drop.fill", label: "Smart Reminders")
                            BenefitPill(icon: "infinity", label: "Track Unlimited")
                        }

                        Spacer()

                        Button {
                            withAnimation { currentPage = 1 }
                        } label: {
                            Text("Next")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.limeGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }
                    .tag(0)

                    // MARK: - Page 2: How it works
                    VStack(spacing: 32) {
                        Spacer()

                        Text("3 Steps. Zero Guesswork.")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 24) {
                            StepRow(number: 1, icon: "camera.fill", title: "Take a photo of your plant", color: .blue)
                            StepRow(number: 2, icon: "sparkles", title: "AI identifies species + care needs", color: .yellow)
                            StepRow(number: 3, icon: "bell.badge.fill", title: "Get reminders when it needs water", color: AppColors.limeGreen)
                        }
                        .padding(.horizontal, 32)

                        Spacer()

                        Button {
                            withAnimation { currentPage = 2 }
                        } label: {
                            Text("Next")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.limeGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }
                    .tag(1)

                    // MARK: - Page 3: Let's go
                    VStack(spacing: 32) {
                        Spacer()

                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 72, weight: .ultraLight))
                            .foregroundStyle(AppColors.limeGreen)

                        VStack(spacing: 12) {
                            Text("Let's Identify Your First Plant")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Point your camera at any houseplant")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()

                        VStack(spacing: 16) {
                            Button {
                                completeOnboarding(openCamera: true)
                            } label: {
                                Text("Identify My First Plant")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(AppColors.limeGreen)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Button {
                                completeOnboarding(openCamera: false)
                            } label: {
                                Text("I'll do this later")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppColors.limeGreen : AppColors.textSecondary.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }

    private func completeOnboarding(openCamera: Bool) {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        isPresented = false
        if openCamera {
            // Small delay to let onboarding dismiss before presenting AddPlantView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                launchAddPlant = true
            }
        }
    }
}

// MARK: - Subviews

private struct BenefitPill: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.limeGreen)
                .frame(width: 48, height: 48)
                .background(AppColors.limeGreen.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

private struct StepRow: View {
    let number: Int
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Step \(number)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()
        }
    }
}

#Preview {
    @State var isPresented = true
    @State var launchAddPlant = false

    return OnboardingView(isPresented: $isPresented, launchAddPlant: $launchAddPlant)
}
