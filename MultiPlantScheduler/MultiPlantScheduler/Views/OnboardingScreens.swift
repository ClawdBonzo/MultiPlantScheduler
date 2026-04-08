import SwiftUI

#if os(iOS)
import UIKit
#endif

/// Screen 1: Welcome to MultiPlant
struct OnboardingWelcomeScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo/Icon
            VStack(spacing: 12) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppBrand.primary)

                Text("MultiPlant")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)

                Text("Scheduler")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(AppText.secondary)
            }

            Spacer()

            // Value Prop
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppSemantic.success)
                    Text("Never forget to water your plants")
                        .font(.body)
                        .foregroundColor(AppText.primary)
                }

                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(AppSemantic.info)
                    Text("AI diagnosis for diseases & pests")
                        .font(.body)
                        .foregroundColor(AppText.primary)
                }

                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppSemantic.warning)
                    Text("Earn rewards with our gamification")
                        .font(.body)
                        .foregroundColor(AppText.primary)
                }
            }
            .padding(20)
            .background(AppSurface.tertiary)
            .cornerRadius(16)

            Spacer()

            // CTA Button
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

/// Screen 2: Features Overview
struct OnboardingFeaturesScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Powerful Features")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)
                Text("Everything you need in one app")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 12) {
                    FeatureCard(
                        icon: "camera.fill",
                        title: "Smart Identification",
                        description: "Point and click to identify 47+ houseplants with AI",
                        color: AppBrand.primary
                    )

                    FeatureCard(
                        icon: "calendar",
                        title: "Smart Reminders",
                        description: "Personalized watering schedules adapted to your climate",
                        color: AppSemantic.info
                    )

                    FeatureCard(
                        icon: "stethoscope",
                        title: "Health Diagnostics",
                        description: "Detect diseases & pests before they spread",
                        color: AppSemantic.critical
                    )

                    FeatureCard(
                        icon: "person.2.fill",
                        title: "Community",
                        description: "Share tips and learn from fellow plant lovers",
                        color: AppSemantic.success
                    )
                }
            }

            // CTA Button
            Button(action: onContinue) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

/// Screen 3: Gamification
struct OnboardingGamificationScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Earn & Achieve")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)
                Text("Get rewarded for plant care")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Gamification preview
            VStack(spacing: 16) {
                // XP
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Earn XP")
                            .font(.headline)
                            .foregroundColor(AppText.primary)
                        Text("Complete daily quests and care tasks")
                            .font(.caption)
                            .foregroundColor(AppText.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(AppSurface.tertiary)
                .cornerRadius(12)

                // Streaks
                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Streaks")
                            .font(.headline)
                            .foregroundColor(AppText.primary)
                        Text("Maintain care streaks for multiplier bonuses")
                            .font(.caption)
                            .foregroundColor(AppText.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(AppSurface.tertiary)
                .cornerRadius(12)

                // Badges
                HStack(spacing: 12) {
                    Image(systemName: "badge.plus.radiowaves.right.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppBrand.primary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unlock Badges")
                            .font(.headline)
                            .foregroundColor(AppText.primary)
                        Text("Achieve milestones and level up")
                            .font(.caption)
                            .foregroundColor(AppText.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(AppSurface.tertiary)
                .cornerRadius(12)

                // Levels
                HStack(spacing: 12) {
                    Image(systemName: "level.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppSemantic.success)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Grow Your Level")
                            .font(.headline)
                            .foregroundColor(AppText.primary)
                        Text("Seedling → Master Gardener → Legendary")
                            .font(.caption)
                            .foregroundColor(AppText.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(AppSurface.tertiary)
                .cornerRadius(12)
            }

            Spacer()

            // CTA Button
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

/// Screen 4: Premium Benefits
struct OnboardingPremiumScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                    Text("Premium")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppText.primary)
                }
                Text("Unlock unlimited power")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 12) {
                    PremiumFeature(
                        icon: "plants.fill",
                        title: "Unlimited Plants",
                        description: "No limits. Care for as many as you want"
                    )

                    PremiumFeature(
                        icon: "sparkles",
                        title: "Unlimited AI Diagnosis",
                        description: "Scan as many plants as needed"
                    )

                    PremiumFeature(
                        icon: "waveform.circle.fill",
                        title: "Advanced Analytics",
                        description: "In-depth care insights and trends"
                    )

                    PremiumFeature(
                        icon: "bolt.fill",
                        title: "Priority Support",
                        description: "Get help from our team"
                    )

                    PremiumFeature(
                        icon: "sparkle",
                        title: "Premium Features",
                        description: "Exclusive tools and customizations"
                    )
                }
            }

            Spacer()

            // CTA Button
            Button(action: onContinue) {
                Text("See Plans")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

/// Screen 5: Reminders & Notifications
struct OnboardingRemindersScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Stay On Track")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)
                Text("Custom watering reminders")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Reminder example
            VStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AppBrand.primary)

                Text("Smart Reminders")
                    .font(.headline)
                    .foregroundColor(AppText.primary)

                VStack(spacing: 8) {
                    Text("✓ Set custom times per plant")
                    Text("✓ Weather-aware schedules")
                    Text("✓ Humidity sensor integration")
                    Text("✓ One-tap watering logs")
                }
                .font(.body)
                .foregroundColor(AppText.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppSurface.tertiary)
                .cornerRadius(12)
            }

            Spacer()

            // CTA Button
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

/// Screen 6: Permissions
struct OnboardingPermissionsScreen: View {
    let onContinue: () -> Void
    @State private var notificationsEnabled = false
    @State private var cameraEnabled = false

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("We Need Permission")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)
                Text("For the best experience")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: 12) {
                PermissionToggle(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Watering reminders & achievements",
                    isEnabled: $notificationsEnabled,
                    action: {
                        #if os(iOS)
                        UNUserNotificationCenter.current()
                            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                        #endif
                    }
                )

                PermissionToggle(
                    icon: "camera.fill",
                    title: "Camera",
                    description: "Plant identification & diagnosis",
                    isEnabled: $cameraEnabled,
                    action: {
                        // Camera permission request handled by UIImagePickerController
                    }
                )
            }

            Spacer()

            // CTA Button
            Button(action: onContinue) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

/// Screen 7: Quick Start
struct OnboardingQuickStartScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("You're Almost There")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)
                Text("3 quick steps to get started")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: 16) {
                QuickStartStep(number: "1", title: "Add your first plant", icon: "leaf.fill")
                QuickStartStep(number: "2", title: "Set watering reminders", icon: "bell.fill")
                QuickStartStep(number: "3", title: "Start earning rewards", icon: "star.fill")
            }

            Spacer()

            // Info box
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppSemantic.success)
                    Text("You can add plants anytime!")
                        .font(.body)
                        .foregroundColor(AppText.secondary)
                }
            }
            .padding(16)
            .background(AppSurface.tertiary)
            .cornerRadius(12)

            // CTA Button
            Button(action: onContinue) {
                Text("Let's Go")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

/// Screen 8: Final CTA
struct OnboardingFinalCTAScreen: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppSemantic.success)

                Text("Ready to Begin!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(AppText.primary)

                Text("Your plant care journey starts here")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }

            Spacer()

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                    Text("100+ plants supported")
                }
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("AI-powered care")
                }
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                    Text("Gamified experience")
                }
            }
            .font(.body)
            .foregroundColor(AppText.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppSurface.tertiary)
            .cornerRadius(12)

            Spacer()

            // Final CTA Button
            Button(action: onComplete) {
                Text("Start Using MultiPlant")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.black)
                    .background(AppBrand.primary)
                    .cornerRadius(14)
            }

            // Skip option
            Button(action: onComplete) {
                Text("Skip for now")
                    .font(.body)
                    .foregroundColor(AppText.secondary)
            }
        }
        .padding(24)
        .background(AppSurface.primary.ignoresSafeArea())
    }
}

// MARK: - Helper Components

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.15))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppText.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppText.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(AppSurface.tertiary)
        .cornerRadius(12)
    }
}

struct PremiumFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppBrand.primary)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppText.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppText.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(AppSurface.tertiary)
        .cornerRadius(12)
    }
}

struct PermissionToggle: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppBrand.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppText.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppText.secondary)
            }

            Spacer()

            Button(action: {
                action()
                isEnabled.toggle()
            }) {
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isEnabled ? AppSemantic.success : AppText.secondary)
            }
        }
        .padding(16)
        .background(AppSurface.tertiary)
        .cornerRadius(12)
    }
}

struct QuickStartStep: View {
    let number: String
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppBrand.primary)
                    .frame(width: 48, height: 48)
                Text(number)
                    .font(.headline)
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppText.primary)
            }

            Spacer()

            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppBrand.primary.opacity(0.5))
        }
        .padding(16)
        .background(AppSurface.tertiary)
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingWelcomeScreen(onContinue: {})
        .background(AppSurface.primary)
}
