#if os(iOS) || os(tvOS)
import UIKit
import CoreHaptics

/// Manages haptic feedback for gamification events
final class HapticManager {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?

    private init() {
        setupHaptics()
    }

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            #if DEBUG
            print("❌ HapticManager — Failed to initialize: \(error)")
            #endif
        }
    }

    // MARK: - Haptic Events

    /// Soft tap for quest progress and interactions
    func softTap() {
        playPattern(.softTap)
    }

    /// Medium success feedback (quest/goal completion)
    func success() {
        playPattern(.success)
    }

    /// Strong celebration (level up, badge unlock)
    func celebration() {
        playPattern(.celebration)
    }

    /// Rhythmic "on fire" streak feedback
    func streakFlame() {
        playPattern(.streakFlame)
    }

    /// Watering feedback - splash-like pattern
    func wateringSplash() {
        playPattern(.wateringSplash)
    }

    /// Bloom effect - delicate flourishing haptics
    func bloom() {
        playPattern(.bloom)
    }

    /// Warning/alert for streak breaking
    func warning() {
        playPattern(.warning)
    }

    /// Light notification
    func notification() {
        playPattern(.notification)
    }

    /// Error or failure
    func error() {
        playPattern(.error)
    }

    // MARK: - Pattern Playback

    private enum HapticPattern {
        case softTap
        case success
        case celebration
        case streakFlame
        case wateringSplash
        case bloom
        case warning
        case notification
        case error

        func pattern() -> CHHapticPattern? {
            let events: [CHHapticEvent]

            switch self {
            case .softTap:
                let tapEvent = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ],
                    relativeTime: 0
                )
                events = [tapEvent]

            case .success:
                let events1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: 0
                )
                let events2 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                    ],
                    relativeTime: 0.1
                )
                events = [events1, events2]

            case .celebration:
                // Three strong pulses
                let p1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: 0
                )
                let p2 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: 0.15
                )
                let p3 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: 0.3
                )
                events = [p1, p2, p3]

            case .streakFlame:
                // Fast escalating pulses for "on fire"
                let pulses = (0..<4).map { index -> CHHapticEvent in
                    let intensity = Float(0.6 + (Double(index) * 0.1))
                    return CHHapticEvent(
                        eventType: .hapticTransient,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.7))
                        ],
                        relativeTime: Double(index) * 0.08
                    )
                }
                events = pulses

            case .wateringSplash:
                // Two taps with diminishing intensity (splash effect)
                let splash1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                    ],
                    relativeTime: 0
                )
                let splash2 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ],
                    relativeTime: 0.1
                )
                events = [splash1, splash2]

            case .bloom:
                // Soft, flourishing pattern
                let b1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: 0
                )
                let b2 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                    ],
                    relativeTime: 0.12
                )
                let b3 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: 0.24
                )
                events = [b1, b2, b3]

            case .warning:
                let warn = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: 0
                )
                events = [warn]

            case .notification:
                let notif = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                    ],
                    relativeTime: 0
                )
                events = [notif]

            case .error:
                let err1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                    ],
                    relativeTime: 0
                )
                let err2 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                    ],
                    relativeTime: 0.1
                )
                events = [err1, err2]
            }

            do {
                return try CHHapticPattern(events: events, parameters: [])
            } catch {
                #if DEBUG
                print("❌ HapticManager — Failed to create pattern: \(error)")
                #endif
                return nil
            }
        }
    }

    private func playPattern(_ pattern: HapticPattern) {
        guard let engine = engine else {
            // Fallback to standard haptics
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
            return
        }

        do {
            guard let hapticPattern = pattern.pattern() else { return }
            try engine.start()
            // Convert CHHapticPattern to Data for playPattern
            let patternData = try NSKeyedArchiver.archivedData(withRootObject: hapticPattern, requiringSecureCoding: false)
            try engine.playPattern(from: patternData)
        } catch {
            #if DEBUG
            print("❌ HapticManager — Failed to play pattern: \(error)")
            #endif
        }
    }
}
#endif
