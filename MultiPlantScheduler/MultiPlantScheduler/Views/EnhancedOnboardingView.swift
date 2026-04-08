import SwiftUI

#if os(iOS)
import UIKit
#endif

/// Enhanced 8-screen onboarding flow with Woofz-style design
struct EnhancedOnboardingView: View {
    @Binding var isPresented: Bool
    @Binding var launchAddPlant: Bool
    @State private var currentStep: Int = 0
    @State private var particles: [FloatingParticle] = []
    @State private var particlesAnimating = false

    private let screenCount = 8

    var body: some View {
        ZStack {
            AppSurface.primary.ignoresSafeArea()

            FloatingParticlesView(particles: particles, animating: particlesAnimating)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Screen content with slide transitions
                Group {
                    switch currentStep {
                    case 0: OnboardingWelcomeScreen(onContinue: advance)
                    case 1: OnboardingFeaturesScreen(onContinue: advance)
                    case 2: OnboardingGamificationScreen(onContinue: advance)
                    case 3: OnboardingPremiumScreen(onContinue: advance)
                    case 4: OnboardingRemindersScreen(onContinue: advance)
                    case 5: OnboardingPermissionsScreen(onContinue: advance)
                    case 6: OnboardingQuickStartScreen(onContinue: advance)
                    case 7: OnboardingFinalCTAScreen(onComplete: completeOnboarding)
                    default: OnboardingWelcomeScreen(onContinue: advance)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                // Page indicators
                if screenCount > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<screenCount, id: \.self) { index in
                            Capsule()
                                .fill(index == currentStep ? AppBrand.primary : AppText.tertiary)
                                .frame(width: index == currentStep ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 0.4)) {
                particlesAnimating = true
            }
        }
    }

    // MARK: - Navigation

    private func advance() {
        guard currentStep < screenCount - 1 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep += 1
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

        withAnimation {
            isPresented = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            launchAddPlant = true
        }
    }

    // MARK: - Particles

    private func generateParticles() {
        particles = (0..<20).map { _ in
            FloatingParticle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 12...20),
                opacity: Double.random(in: 0.04...0.14),
                speed: Double.random(in: 6...14),
                horizontalDrift: CGFloat.random(in: -25...25),
                icon: ["leaf.fill", "leaf", "sparkle"].randomElement()!
            )
        }
    }
}

#Preview {
    EnhancedOnboardingView(isPresented: .constant(true), launchAddPlant: .constant(false))
}
