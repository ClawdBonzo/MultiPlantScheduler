/// v1.2 — Value-first onboarding: 4 cinematic screens, no paywall
/// 1. Welcome  2. AI ID Demo  3. Reminders & Timeline  4. Start scanning CTA

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @Binding var launchAddPlant: Bool

    @State private var currentStep: OnboardingStep = .welcome
    @State private var particles: [FloatingParticle] = []
    @State private var particlesAnimating = false

    private enum OnboardingStep: Int, CaseIterable {
        case welcome, aiDemo, benefits, readyToScan
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Floating leaf particles behind all screens
            FloatingParticlesView(particles: particles, animating: particlesAnimating)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Screen content
                Group {
                    switch currentStep {
                    case .welcome:
                        WelcomeScreen(onContinue: { advance() })
                    case .aiDemo:
                        AIDemoScreen(onContinue: { advance() })
                    case .benefits:
                        BenefitsScreen(onContinue: { advance() })
                    case .readyToScan:
                        ReadyToScanScreen(onStartScanning: { completeOnboarding() })
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                // Page dots
                HStack(spacing: 8) {
                    ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                        Capsule()
                            .fill(step == currentStep ? AppColors.limeGreen : Color.white.opacity(0.15))
                            .frame(width: step == currentStep ? 28 : 8, height: 8)
                            .shadow(color: step == currentStep ? AppColors.limeGreen.opacity(0.5) : .clear, radius: 4)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                    }
                }
                .padding(.bottom, 20)
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
        let allSteps = OnboardingStep.allCases
        guard let idx = allSteps.firstIndex(of: currentStep),
              idx + 1 < allSteps.count else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = allSteps[idx + 1]
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        isPresented = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            launchAddPlant = true
        }
    }

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

// MARK: - Screen 1: Welcome

private struct WelcomeScreen: View {
    let onContinue: () -> Void

    @State private var heroScale: CGFloat = 0.3
    @State private var heroOpacity: Double = 0
    @State private var heroRotation: Double = -120
    @State private var glowPulse = false
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var ctaOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero icon with glow
            ZStack {
                // Pulsing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.limeGreen.opacity(0.12), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(glowPulse ? 1.2 : 0.9)

                // Outer ring
                Circle()
                    .stroke(AppColors.limeGreen.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 160, height: 160)
                    .scaleEffect(heroScale)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 100, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.forestGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(heroScale)
                    .rotationEffect(.degrees(heroRotation))
                    .opacity(heroOpacity)
                    .shadow(color: AppColors.limeGreen.opacity(0.5), radius: 24)
            }
            .padding(.bottom, 36)

            // Title
            VStack(spacing: 12) {
                Text("Identify Any\nHouseplant Instantly")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                Text("Point your camera at a plant.\nAI tells you what it is and how to care for it.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(subtitleOpacity)
            }
            .padding(.horizontal, 28)

            Spacer()

            // CTA
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.limeGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 12, y: 4)
            }
            .opacity(ctaOpacity)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .onAppear { animate() }
    }

    private func animate() {
        // Hero springs in with rotation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.55).delay(0.1)) {
            heroScale = 1.0
            heroOpacity = 1.0
            heroRotation = 0
        }
        // Glow pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
        // Title
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35)) {
            titleOpacity = 1.0
            titleOffset = 0
        }
        // Subtitle
        withAnimation(.easeOut(duration: 0.4).delay(0.55)) {
            subtitleOpacity = 1.0
        }
        // CTA
        withAnimation(.easeOut(duration: 0.4).delay(0.75)) {
            ctaOpacity = 1.0
        }
    }
}

// MARK: - Screen 2: AI Identification Demo

private struct AIDemoScreen: View {
    let onContinue: () -> Void

    @State private var phase: DemoPhase = .viewfinder
    @State private var scanLineY: CGFloat = -100
    @State private var pulseScale: CGFloat = 1.0
    @State private var resultOpacity: Double = 0
    @State private var resultOffset: CGFloat = 60
    @State private var ctaOpacity: Double = 0

    private enum DemoPhase { case viewfinder, scanning, result }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            Text(phase == .result ? "Identified!" : "AI Plant Scanner")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, 20)

            // Viewfinder
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.08))
                    .frame(width: 260, height: 260)

                // Plant silhouette
                Text("🌿")
                    .font(.system(size: 90))
                    .opacity(phase == .result ? 0.3 : 0.5)

                // Corner brackets
                ViewfinderCorners()
                    .stroke(
                        phase == .result ? AppColors.limeGreen : AppColors.limeGreen.opacity(0.7),
                        lineWidth: 2.5
                    )
                    .frame(width: 220, height: 220)

                // Scan line
                if phase == .scanning {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, AppColors.limeGreen.opacity(0.6), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 200, height: 3)
                        .offset(y: scanLineY)
                        .shadow(color: AppColors.limeGreen.opacity(0.5), radius: 8)
                }

                // Pulse ring
                if phase == .scanning {
                    Circle()
                        .stroke(AppColors.limeGreen.opacity(0.2), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulseScale)
                        .opacity(2.0 - Double(pulseScale))
                }

                // Scan status
                if phase == .scanning {
                    VStack {
                        Spacer()
                        Text("🔍 Identifying…")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.limeGreen)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Capsule())
                    }
                    .frame(width: 220, height: 220)
                }
            }
            .padding(.bottom, 20)

            // Result card
            if phase == .result {
                VStack(spacing: 14) {
                    // Plant ID
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.forestGreen, AppColors.limeGreen],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                            Text("🌿")
                                .font(.system(size: 24))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Monstera deliciosa")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Text("Swiss Cheese Plant")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    }

                    // Care info pills
                    HStack(spacing: 8) {
                        carePill(icon: "💧", text: "Every 7 days")
                        carePill(icon: "☀️", text: "Bright indirect")
                        carePill(icon: "🌡️", text: "65–85°F")
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.limeGreen.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .opacity(resultOpacity)
                .offset(y: resultOffset)
            }

            Spacer()

            // CTA
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.limeGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 12, y: 4)
            }
            .opacity(ctaOpacity)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .onAppear { startDemo() }
    }

    @ViewBuilder
    private func carePill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(AppColors.forestGreen.opacity(0.2))
        .clipShape(Capsule())
    }

    private func startDemo() {
        // Brief viewfinder pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            phase = .scanning

            // Scan line sweep
            withAnimation(.easeInOut(duration: 1.0).repeatCount(2, autoreverses: true)) {
                scanLineY = 100
            }
            // Pulse ring
            withAnimation(.easeOut(duration: 0.8).repeatCount(3, autoreverses: false)) {
                pulseScale = 2.0
            }
        }

        // Result
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            phase = .result

            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                resultOpacity = 1
                resultOffset = 0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                ctaOpacity = 1
            }
        }
    }
}

// MARK: - Screen 3: Smart Reminders & Photo Timeline

private struct BenefitsScreen: View {
    let onContinue: () -> Void

    @State private var headerOpacity: Double = 0
    @State private var card1Visible = false
    @State private var card2Visible = false
    @State private var card3Visible = false
    @State private var ctaOpacity: Double = 0

    private let benefits: [(icon: String, systemIcon: String, title: String, detail: String)] = [
        ("💧", "bell.badge", "Smart Watering Reminders", "Custom notification times per plant — never overwater or underwater again."),
        ("📸", "camera.viewfinder", "Photo Growth Timeline", "Track your plant's journey with photos and see the transformation over time."),
        ("🩺", "heart.text.clipboard", "Health Check-Ins", "Log your plant's condition and catch problems early with care history."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Header
            VStack(spacing: 10) {
                Text("Everything Your\nPlants Need")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Built-in tools to help your garden thrive")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .opacity(headerOpacity)
            .padding(.bottom, 32)

            // Benefit cards
            VStack(spacing: 14) {
                benefitCard(benefits[0], visible: card1Visible)
                benefitCard(benefits[1], visible: card2Visible)
                benefitCard(benefits[2], visible: card3Visible)
            }
            .padding(.horizontal, 24)

            Spacer()

            // CTA
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.limeGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 12, y: 4)
            }
            .opacity(ctaOpacity)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .onAppear { animate() }
    }

    @ViewBuilder
    private func benefitCard(
        _ b: (icon: String, systemIcon: String, title: String, detail: String),
        visible: Bool
    ) -> some View {
        HStack(spacing: 14) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(AppColors.limeGreen.opacity(0.1))
                    .frame(width: 48, height: 48)
                Text(b.icon)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(b.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text(b.detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 20)
        .scaleEffect(visible ? 1 : 0.95)
    }

    private func animate() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
            headerOpacity = 1
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3)) {
            card1Visible = true
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.45)) {
            card2Visible = true
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.6)) {
            card3Visible = true
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
            ctaOpacity = 1
        }
    }
}

// MARK: - Screen 4: Ready to Scan

private struct ReadyToScanScreen: View {
    let onStartScanning: () -> Void

    @State private var iconScale: CGFloat = 0.3
    @State private var iconOpacity: Double = 0
    @State private var ringPulse = false
    @State private var ring1Scale: CGFloat = 0.6
    @State private var ring2Scale: CGFloat = 0.5
    @State private var ring3Scale: CGFloat = 0.4
    @State private var titleOpacity: Double = 0
    @State private var ctaOpacity: Double = 0
    @State private var ctaScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Camera icon with expanding rings
            ZStack {
                // Ring 3 (outermost)
                Circle()
                    .stroke(AppColors.limeGreen.opacity(ringPulse ? 0.06 : 0.12), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                    .scaleEffect(ring3Scale)

                // Ring 2
                Circle()
                    .stroke(AppColors.limeGreen.opacity(ringPulse ? 0.1 : 0.18), lineWidth: 2)
                    .frame(width: 160, height: 160)
                    .scaleEffect(ring2Scale)

                // Ring 1
                Circle()
                    .stroke(AppColors.limeGreen.opacity(ringPulse ? 0.15 : 0.25), lineWidth: 2.5)
                    .frame(width: 120, height: 120)
                    .scaleEffect(ring1Scale)

                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.limeGreen.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(ringPulse ? 1.15 : 0.9)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 72, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 16)
            }
            .padding(.bottom, 36)

            VStack(spacing: 12) {
                Text("Ready to Care for\nYour Plants?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Point your camera at any houseplant\nto identify it and start tracking its care.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .opacity(titleOpacity)
            .padding(.horizontal, 28)

            Spacer()

            // Primary CTA — opens camera
            VStack(spacing: 14) {
                Button {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        ctaScale = 0.92
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            ctaScale = 1.05
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            ctaScale = 1.0
                        }
                        onStartScanning()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Start Scanning My First Plant")
                    }
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: AppColors.limeGreen.opacity(0.5), radius: 16, y: 6)
                }
                .scaleEffect(ctaScale)
            }
            .opacity(ctaOpacity)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .onAppear { animate() }
    }

    private func animate() {
        // Icon springs in
        withAnimation(.spring(response: 0.7, dampingFraction: 0.55).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        // Rings expand
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.15)) {
            ring1Scale = 1.0
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.25)) {
            ring2Scale = 1.0
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.35)) {
            ring3Scale = 1.0
        }
        // Continuous pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                ringPulse = true
            }
        }
        // Title
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            titleOpacity = 1.0
        }
        // CTA
        withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
            ctaOpacity = 1.0
        }
    }
}

// MARK: - Viewfinder Corners Shape

private struct ViewfinderCorners: Shape {
    func path(in rect: CGRect) -> Path {
        let len: CGFloat = 28
        var path = Path()
        // Top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + len))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + len, y: rect.minY))
        // Top-right
        path.move(to: CGPoint(x: rect.maxX - len, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + len))
        // Bottom-right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - len))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - len, y: rect.maxY))
        // Bottom-left
        path.move(to: CGPoint(x: rect.minX + len, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - len))
        return path
    }
}

// MARK: - Floating Particles

struct FloatingParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let speed: Double
    var horizontalDrift: CGFloat = 0
    let icon: String
}

struct FloatingParticlesView: View {
    let particles: [FloatingParticle]
    let animating: Bool

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Image(systemName: particle.icon)
                    .font(.system(size: particle.size))
                    .foregroundStyle(AppColors.limeGreen.opacity(particle.opacity))
                    .shadow(color: AppColors.limeGreen.opacity(particle.opacity * 0.5), radius: 4)
                    .position(
                        x: (particle.x * geo.size.width) + (animating ? particle.horizontalDrift : -particle.horizontalDrift),
                        y: animating
                            ? (particle.y * geo.size.height) - 60
                            : (particle.y * geo.size.height) + 60
                    )
                    .animation(
                        .easeInOut(duration: particle.speed)
                        .repeatForever(autoreverses: true),
                        value: animating
                    )
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var launchAddPlant = false

    OnboardingView(isPresented: $isPresented, launchAddPlant: $launchAddPlant)
}
