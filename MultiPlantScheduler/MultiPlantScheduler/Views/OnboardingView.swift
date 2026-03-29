import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @Binding var launchAddPlant: Bool
    @State private var currentPage = 0

    // Page 1 animations
    @State private var heroScale: CGFloat = 0.3
    @State private var heroRotation: Double = -180
    @State private var heroOpacity: Double = 0
    @State private var heroGlowScale: CGFloat = 0.5
    @State private var heroGlowPulse = false
    @State private var pillsVisible = false
    @State private var pill1Scale: CGFloat = 0.3
    @State private var pill2Scale: CGFloat = 0.3
    @State private var pill3Scale: CGFloat = 0.3
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0

    // Page 2 animations
    @State private var step1Visible = false
    @State private var step2Visible = false
    @State private var step3Visible = false
    @State private var stepTitleOpacity: Double = 0

    // Page 3 animations
    @State private var cameraPulse = false
    @State private var ring1Scale: CGFloat = 0.6
    @State private var ring2Scale: CGFloat = 0.5
    @State private var ring3Scale: CGFloat = 0.4
    @State private var ctaScale: CGFloat = 1.0
    @State private var page3ContentOpacity: Double = 0

    // Floating particles
    @State private var particles: [FloatingParticle] = []
    @State private var particlesAnimating = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Subtle green gradient at bottom
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, AppColors.limeGreen.opacity(0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
            }
            .ignoresSafeArea()

            // Floating leaf particles
            FloatingParticlesView(particles: particles, animating: particlesAnimating)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    page1HookView.tag(0)
                    page2StepsView.tag(1)
                    page3CTAView.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppColors.limeGreen : AppColors.textSecondary.opacity(0.3))
                            .frame(width: index == currentPage ? 28 : 8, height: 8)
                            .shadow(color: index == currentPage ? AppColors.limeGreen.opacity(0.5) : .clear, radius: 4)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 0.4)) {
                particlesAnimating = true
            }
            animatePage1()
        }
        .onChange(of: currentPage) { _, newPage in
            if newPage == 1 { animatePage2() }
            if newPage == 2 { animatePage3() }
        }
    }

    // MARK: - Page 1: Hook

    private var page1HookView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Hero icon with dramatic entrance
            ZStack {
                // Outer pulsing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.limeGreen.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                    .scaleEffect(heroGlowPulse ? 1.3 : 0.9)
                    .opacity(heroOpacity)

                // Inner glow ring
                Circle()
                    .stroke(AppColors.limeGreen.opacity(0.2), lineWidth: 2)
                    .frame(width: 160, height: 160)
                    .scaleEffect(heroGlowScale)
                    .opacity(heroOpacity)

                // Middle glow ring
                Circle()
                    .stroke(AppColors.limeGreen.opacity(0.1), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                    .scaleEffect(heroGlowScale * 1.2)
                    .opacity(heroOpacity)

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
                    .shadow(color: AppColors.limeGreen.opacity(0.6), radius: 30)
            }

            VStack(spacing: 12) {
                Text("Identify Any Plant\nInstantly")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                Text("Snap a photo. AI tells you what it is\nand when to water it.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
            }

            // Benefit pills with staggered spring scale
            HStack(spacing: 16) {
                BenefitPill(icon: "camera.viewfinder", label: "AI Plant ID")
                    .scaleEffect(pill1Scale)
                    .opacity(pill1Scale > 0.5 ? 1 : 0)

                BenefitPill(icon: "drop.fill", label: "Smart Reminders")
                    .scaleEffect(pill2Scale)
                    .opacity(pill2Scale > 0.5 ? 1 : 0)

                BenefitPill(icon: "chart.line.uptrend.xyaxis", label: "Track Growth")
                    .scaleEffect(pill3Scale)
                    .opacity(pill3Scale > 0.5 ? 1 : 0)
            }

            Spacer()

            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                withAnimation { currentPage = 1 }
            } label: {
                Text("Next")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 12, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Page 2: Steps

    private var page2StepsView: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("3 Steps. Zero Guesswork.")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(stepTitleOpacity)

            VStack(spacing: 20) {
                AnimatedStepRow(number: 1, icon: "camera.fill", title: "Take a photo of your plant", color: .blue, isVisible: step1Visible)
                AnimatedStepRow(number: 2, icon: "sparkles", title: "AI identifies species + care needs", color: .yellow, isVisible: step2Visible)
                AnimatedStepRow(number: 3, icon: "bell.badge.fill", title: "Get reminders when it needs water", color: AppColors.limeGreen, isVisible: step3Visible)
            }
            .padding(.horizontal, 28)

            Spacer()

            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                withAnimation { currentPage = 2 }
            } label: {
                Text("Next")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 12, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Page 3: CTA

    private var page3CTAView: some View {
        VStack(spacing: 28) {
            Spacer()

            // Pulsing camera with 3 expanding rings
            ZStack {
                // Ring 3 (outermost)
                Circle()
                    .stroke(AppColors.limeGreen.opacity(cameraPulse ? 0.06 : 0.15), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                    .scaleEffect(ring3Scale)

                // Ring 2
                Circle()
                    .stroke(AppColors.limeGreen.opacity(cameraPulse ? 0.1 : 0.2), lineWidth: 2)
                    .frame(width: 160, height: 160)
                    .scaleEffect(ring2Scale)

                // Ring 1 (innermost)
                Circle()
                    .stroke(AppColors.limeGreen.opacity(cameraPulse ? 0.15 : 0.3), lineWidth: 2.5)
                    .frame(width: 120, height: 120)
                    .scaleEffect(ring1Scale)

                // Glow behind icon
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.limeGreen.opacity(0.12), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(cameraPulse ? 1.15 : 0.9)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 80, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(cameraPulse ? 1.08 : 0.92)
                    .shadow(color: AppColors.limeGreen.opacity(0.5), radius: 20)
            }
            .opacity(page3ContentOpacity)

            VStack(spacing: 12) {
                Text("Let's Identify Your\nFirst Plant")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Point your camera at any houseplant")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(page3ContentOpacity)

            Spacer()

            VStack(spacing: 16) {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                        ctaScale = 0.88
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                            ctaScale = 1.05
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            ctaScale = 1.0
                        }
                        completeOnboarding(openCamera: true)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Identify My First Plant")
                    }
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: AppColors.limeGreen.opacity(0.5), radius: 16, y: 6)
                }
                .scaleEffect(ctaScale)

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
    }

    // MARK: - Animation Triggers

    private func animatePage1() {
        // Hero icon: dramatic spring from tiny + full rotation
        withAnimation(.spring(response: 1.0, dampingFraction: 0.55).delay(0.15)) {
            heroScale = 1.0
            heroRotation = 0
            heroOpacity = 1.0
        }

        // Glow rings expand
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            heroGlowScale = 1.0
        }

        // Start continuous glow pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                heroGlowPulse = true
            }
        }

        // Title slides up + fades in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.45)) {
            titleOpacity = 1.0
            titleOffset = 0
        }

        // Pills spring in staggered
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.65)) {
            pill1Scale = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.8)) {
            pill2Scale = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.95)) {
            pill3Scale = 1.0
        }
    }

    private func animatePage2() {
        step1Visible = false
        step2Visible = false
        step3Visible = false
        stepTitleOpacity = 0

        withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1)) {
            stepTitleOpacity = 1.0
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.55).delay(0.25)) {
            step1Visible = true
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.55).delay(0.45)) {
            step2Visible = true
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.55).delay(0.65)) {
            step3Visible = true
        }
    }

    private func animatePage3() {
        // Content fades in
        withAnimation(.easeOut(duration: 0.4)) {
            page3ContentOpacity = 1.0
        }

        // Rings expand outward
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
            ring1Scale = 1.0
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2)) {
            ring2Scale = 1.0
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            ring3Scale = 1.0
        }

        // Start continuous pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                cameraPulse = true
            }
        }
    }

    private func generateParticles() {
        particles = (0..<28).map { _ in
            FloatingParticle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 12...22),
                opacity: Double.random(in: 0.06...0.2),
                speed: Double.random(in: 5...14),
                horizontalDrift: CGFloat.random(in: -30...30),
                icon: ["leaf.fill", "leaf", "sparkle", "leaf.fill"].randomElement()!
            )
        }
    }

    private func completeOnboarding(openCamera: Bool) {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        isPresented = false
        if openCamera {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                launchAddPlant = true
            }
        }
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

// MARK: - Subviews

private struct BenefitPill: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppColors.limeGreen.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(AppColors.limeGreen)
                    .shadow(color: AppColors.limeGreen.opacity(0.3), radius: 4)
            }

            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

private struct AnimatedStepRow: View {
    let number: Int
    let icon: String
    let title: String
    let color: Color
    let isVisible: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                // Glow behind icon on appear
                Circle()
                    .fill(color.opacity(isVisible ? 0.2 : 0))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isVisible ? 1.1 : 0.5)

                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(color)
                    .scaleEffect(isVisible ? 1.0 : 0.2)
                    .shadow(color: color.opacity(0.4), radius: isVisible ? 6 : 0)
            }

            VStack(alignment: .leading, spacing: 3) {
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
        .padding(.vertical, 6)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
        .scaleEffect(isVisible ? 1.0 : 0.6)
    }
}

#Preview {
    @State var isPresented = true
    @State var launchAddPlant = false

    return OnboardingView(isPresented: $isPresented, launchAddPlant: $launchAddPlant)
}
