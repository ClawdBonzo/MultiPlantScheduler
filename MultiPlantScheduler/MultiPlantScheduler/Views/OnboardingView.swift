import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @Binding var launchAddPlant: Bool
    @State private var currentPage = 0

    // Page 1 animations
    @State private var heroScale: CGFloat = 0.6
    @State private var heroRotation: Double = -15
    @State private var heroOpacity: Double = 0
    @State private var pillsOpacity: Double = 0
    @State private var titleOpacity: Double = 0

    // Page 2 animations
    @State private var step1Visible = false
    @State private var step2Visible = false
    @State private var step3Visible = false

    // Page 3 animations
    @State private var cameraPulse = false
    @State private var ctaScale: CGFloat = 1.0

    // Floating particles
    @State private var particles: [FloatingParticle] = []
    @State private var particlesAnimating = false

    var body: some View {
        ZStack {
            // Background
            AppColors.background.ignoresSafeArea()

            // Floating leaf particles throughout onboarding
            FloatingParticlesView(particles: particles, animating: particlesAnimating)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    // MARK: - Page 1: Hook
                    page1HookView
                        .tag(0)

                    // MARK: - Page 2: How it works
                    page2StepsView
                        .tag(1)

                    // MARK: - Page 3: Let's go
                    page3CTAView
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)

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
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 0.6)) {
                particlesAnimating = true
            }
            animatePage1()
        }
        .onChange(of: currentPage) { _, newPage in
            if newPage == 1 { animatePage2() }
            if newPage == 2 { animatePage3() }
        }
    }

    // MARK: - Page 1

    private var page1HookView: some View {
        VStack(spacing: 28) {
            Spacer()

            // Animated hero icon
            ZStack {
                // Glow ring behind icon
                Circle()
                    .fill(AppColors.limeGreen.opacity(0.08))
                    .frame(width: 160, height: 160)
                    .scaleEffect(heroScale * 1.2)

                Circle()
                    .fill(AppColors.limeGreen.opacity(0.04))
                    .frame(width: 200, height: 200)
                    .scaleEffect(heroScale * 1.4)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 90, weight: .light))
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
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 20)
            }

            VStack(spacing: 12) {
                Text("Identify Any Plant\nInstantly")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)

                Text("Snap a photo. AI tells you what it is\nand when to water it.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
            }

            // Benefit pills with staggered fade-in
            HStack(spacing: 16) {
                BenefitPill(icon: "camera.viewfinder", label: "AI Plant ID")
                BenefitPill(icon: "drop.fill", label: "Smart Reminders")
                BenefitPill(icon: "chart.line.uptrend.xyaxis", label: "Track Growth")
            }
            .opacity(pillsOpacity)

            Spacer()

            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
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
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Page 2

    private var page2StepsView: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("3 Steps. Zero Guesswork.")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                AnimatedStepRow(number: 1, icon: "camera.fill", title: "Take a photo of your plant", color: .blue, isVisible: step1Visible)
                AnimatedStepRow(number: 2, icon: "sparkles", title: "AI identifies species + care needs", color: .yellow, isVisible: step2Visible)
                AnimatedStepRow(number: 3, icon: "bell.badge.fill", title: "Get reminders when it needs water", color: AppColors.limeGreen, isVisible: step3Visible)
            }
            .padding(.horizontal, 28)

            Spacer()

            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
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
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Page 3

    private var page3CTAView: some View {
        VStack(spacing: 28) {
            Spacer()

            // Pulsing camera viewfinder
            ZStack {
                // Animated rings
                Circle()
                    .stroke(AppColors.limeGreen.opacity(0.15), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .scaleEffect(cameraPulse ? 1.15 : 1.0)

                Circle()
                    .stroke(AppColors.limeGreen.opacity(0.08), lineWidth: 1.5)
                    .frame(width: 170, height: 170)
                    .scaleEffect(cameraPulse ? 1.1 : 0.95)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 76, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(cameraPulse ? 1.03 : 0.97)
                    .shadow(color: AppColors.limeGreen.opacity(0.3), radius: 15)
            }

            VStack(spacing: 12) {
                Text("Let's Identify Your\nFirst Plant")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
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
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        ctaScale = 0.92
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            ctaScale = 1.0
                        }
                        completeOnboarding(openCamera: true)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Identify My First Plant")
                    }
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppColors.limeGreen, AppColors.limeGreen.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: AppColors.limeGreen.opacity(0.4), radius: 10, y: 4)
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

    // MARK: - Animations

    private func animatePage1() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.1)) {
            heroScale = 1.0
            heroRotation = 0
            heroOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            titleOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            pillsOpacity = 1.0
        }
    }

    private func animatePage2() {
        step1Visible = false
        step2Visible = false
        step3Visible = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15)) {
            step1Visible = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35)) {
            step2Visible = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.55)) {
            step3Visible = true
        }
    }

    private func animatePage3() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            cameraPulse = true
        }
    }

    private func generateParticles() {
        particles = (0..<18).map { _ in
            FloatingParticle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 8...18),
                opacity: Double.random(in: 0.03...0.12),
                speed: Double.random(in: 8...20),
                icon: ["leaf.fill", "leaf", "sparkle"].randomElement()!
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
                    .position(
                        x: particle.x * geo.size.width,
                        y: animating
                            ? (particle.y * geo.size.height) - 40
                            : (particle.y * geo.size.height) + 40
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
                    .fill(AppColors.limeGreen.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColors.limeGreen)
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
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(color)
                    .scaleEffect(isVisible ? 1 : 0.4)
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
        .padding(.vertical, 4)
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
    }
}

#Preview {
    @State var isPresented = true
    @State var launchAddPlant = false

    return OnboardingView(isPresented: $isPresented, launchAddPlant: $launchAddPlant)
}
