import SwiftData
import SwiftUI
import Foundation

/// A community tip shared by users — hardcoded seeds + user-submitted via SwiftData
@Model
final class CommunityTip {
    var id: UUID = UUID()
    var createdAt: Date = Date.now
    var plantName: String = ""           // e.g. "Monstera", "Snake Plant"
    var tipTitle: String = ""            // e.g. "Bottom watering changed everything"
    var tipDescription: String = ""      // Full tip text
    var category: String = "care"        // "care", "disease", "pest", "watering", "light", "soil", "general"
    var helpfulCount: Int = 0            // Upvote counter
    var photoData: Data?                 // Optional photo
    var authorName: String = "Plant Lover" // Anonymized
    var isSeeded: Bool = false           // true = hardcoded, false = user-submitted
    var relatedDisease: String?          // If tip relates to a specific disease/pest

    init(
        plantName: String,
        tipTitle: String,
        tipDescription: String,
        category: String = "care",
        helpfulCount: Int = 0,
        authorName: String = "Plant Lover",
        isSeeded: Bool = false,
        relatedDisease: String? = nil,
        photoData: Data? = nil
    ) {
        self.id = UUID()
        self.createdAt = Date.now
        self.plantName = plantName
        self.tipTitle = tipTitle
        self.tipDescription = tipDescription
        self.category = category
        self.helpfulCount = helpfulCount
        self.authorName = authorName
        self.isSeeded = isSeeded
        self.relatedDisease = relatedDisease
        self.photoData = photoData
    }

    // MARK: - Computed

    var photoImage: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else { return nil }
        return Image(uiImage: uiImage)
    }

    var tipCategory: TipCategory {
        TipCategory(rawValue: category) ?? .general
    }
}

// MARK: - Tip Category

enum TipCategory: String, CaseIterable, Identifiable {
    case care, disease, pest, watering, light, soil, general

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .care: return "Care"
        case .disease: return "Disease"
        case .pest: return "Pest"
        case .watering: return "Watering"
        case .light: return "Light"
        case .soil: return "Soil"
        case .general: return "General"
        }
    }

    var emoji: String {
        switch self {
        case .care: return "🌱"
        case .disease: return "🦠"
        case .pest: return "🐛"
        case .watering: return "💧"
        case .light: return "☀️"
        case .soil: return "🪴"
        case .general: return "💡"
        }
    }

    var iconName: String {
        switch self {
        case .care: return "leaf.fill"
        case .disease: return "allergens"
        case .pest: return "ant.fill"
        case .watering: return "drop.fill"
        case .light: return "sun.max.fill"
        case .soil: return "mountain.2.fill"
        case .general: return "lightbulb.fill"
        }
    }

    var color: Color {
        switch self {
        case .care: return Constants.Colors.forestGreen
        case .disease: return .purple
        case .pest: return .orange
        case .watering: return .blue
        case .light: return .yellow
        case .soil: return .brown
        case .general: return Constants.Colors.limeGreen
        }
    }
}

// MARK: - Seed Data

struct CommunityTipSeeder {
    static let seedKey = "communityTipsSeeded_v1"

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seedKey) else { return }

        for tip in seeds {
            context.insert(tip)
        }
        try? context.save()
        UserDefaults.standard.set(true, forKey: seedKey)

        #if DEBUG
        print("🌍 CommunityTipSeeder — seeded \(seeds.count) tips")
        #endif
    }

    static var seeds: [CommunityTip] {
        [
            // Watering tips
            CommunityTip(
                plantName: "Monstera",
                tipTitle: "Bottom watering changed everything",
                tipDescription: "I switched my Monstera to bottom watering and the difference is incredible. Roots are stronger, no more yellowing leaves, and I never overwater. Just fill a tray and let it soak for 30 min.",
                category: "watering",
                helpfulCount: 1247,
                authorName: "MonsteraFan",
                isSeeded: true
            ),
            CommunityTip(
                plantName: "Snake Plant",
                tipTitle: "Less is more — seriously",
                tipDescription: "I killed 3 snake plants before I learned: water only every 3-4 weeks. They thrive on neglect. The #1 mistake is overwatering. Let the soil dry completely between waterings.",
                category: "watering",
                helpfulCount: 2103,
                authorName: "DesertLover",
                isSeeded: true
            ),
            CommunityTip(
                plantName: "Pothos",
                tipTitle: "Ice cube watering hack",
                tipDescription: "For small pothos pots, I drop 2-3 ice cubes instead of watering directly. Prevents overwatering and gives slow, even moisture. My pothos has never looked better!",
                category: "watering",
                helpfulCount: 893,
                authorName: "PlantHacker",
                isSeeded: true
            ),

            // Disease tips
            CommunityTip(
                plantName: "Fiddle Leaf Fig",
                tipTitle: "How I beat root rot",
                tipDescription: "Root rot nearly killed my fiddle leaf. What saved it: removed from pot, cut all brown mushy roots, dipped in hydrogen peroxide 3%, repotted in fresh well-draining mix. Took 6 weeks to recover but it's thriving now.",
                category: "disease",
                helpfulCount: 1891,
                authorName: "FigSaver",
                isSeeded: true,
                relatedDisease: "Root Rot"
            ),
            CommunityTip(
                plantName: "Rose",
                tipTitle: "Neem oil saved my roses from powdery mildew",
                tipDescription: "Mix 2 tsp neem oil + 1 tsp dish soap in a quart of water. Spray every 7 days. After 3 weeks, powdery mildew was completely gone. Prevention is key — spray before you see it.",
                category: "disease",
                helpfulCount: 1456,
                authorName: "RoseWhisperer",
                isSeeded: true,
                relatedDisease: "Powdery Mildew"
            ),
            CommunityTip(
                plantName: "Orchid",
                tipTitle: "Cinnamon for fungal issues",
                tipDescription: "When my orchid got a fungal spot, I dabbed plain cinnamon powder on the affected area. It's a natural fungicide! Dried up the spot in days. Now I always keep cinnamon near my plants.",
                category: "disease",
                helpfulCount: 734,
                authorName: "OrchidLove",
                isSeeded: true,
                relatedDisease: "Fungal Leaf Spot"
            ),

            // Pest tips
            CommunityTip(
                plantName: "Calathea",
                tipTitle: "Spider mites? Shower your plants!",
                tipDescription: "I put my Calathea in the shower and blasted the leaves with lukewarm water. Did this every 3 days for 2 weeks. Combined with wiping leaves with soapy water, mites were gone. Prevention: mist leaves daily.",
                category: "pest",
                helpfulCount: 1567,
                authorName: "MiteFighter",
                isSeeded: true,
                relatedDisease: "Spider Mites"
            ),
            CommunityTip(
                plantName: "Succulent",
                tipTitle: "Rubbing alcohol vs mealybugs",
                tipDescription: "Dip a Q-tip in 70% isopropyl alcohol and dab each mealybug directly. They dissolve on contact. Check crevices and undersides. Repeat every 5 days until clear. Works 100% of the time.",
                category: "pest",
                helpfulCount: 2341,
                authorName: "SucculentQueen",
                isSeeded: true,
                relatedDisease: "Mealybugs"
            ),
            CommunityTip(
                plantName: "Herb Garden",
                tipTitle: "Sticky traps + sand layer for fungus gnats",
                tipDescription: "Yellow sticky traps catch adults, but to break the cycle you need to stop larvae. Add a 1/2 inch layer of sand on top of soil. Gnats can't lay eggs through it. Problem solved in 2 weeks.",
                category: "pest",
                helpfulCount: 1823,
                authorName: "HerbGardener",
                isSeeded: true,
                relatedDisease: "Fungus Gnats"
            ),

            // Light tips
            CommunityTip(
                plantName: "ZZ Plant",
                tipTitle: "Thrives in my windowless bathroom",
                tipDescription: "Everyone said ZZ plants need some light. Mine has been in a windowless bathroom for 8 months and it's actually growing new shoots. The fluorescent light is enough. Perfect office plant too.",
                category: "light",
                helpfulCount: 967,
                authorName: "DarkRoomPlants",
                isSeeded: true
            ),
            CommunityTip(
                plantName: "Fiddle Leaf Fig",
                tipTitle: "Rotate 1/4 turn weekly",
                tipDescription: "My fiddle leaf was growing lopsided toward the window. Started rotating it 90 degrees every Sunday. Now it grows straight and full on all sides. Such a simple fix!",
                category: "light",
                helpfulCount: 1134,
                authorName: "FiddleFixer",
                isSeeded: true
            ),

            // Soil tips
            CommunityTip(
                plantName: "Alocasia",
                tipTitle: "Chunky mix = happy roots",
                tipDescription: "Standard potting soil was suffocating my Alocasia. Switched to: 40% orchid bark, 30% perlite, 20% potting soil, 10% charcoal. Roots are massive now and no more root rot. Game changer for aroids.",
                category: "soil",
                helpfulCount: 1678,
                authorName: "AroidAddict",
                isSeeded: true
            ),

            // General care tips
            CommunityTip(
                plantName: "All Plants",
                tipTitle: "Hydrogen peroxide for healthy roots",
                tipDescription: "Once a month I water with 1 part 3% hydrogen peroxide to 4 parts water. It adds oxygen to the soil, kills harmful bacteria, and prevents root rot. My plants have never been healthier.",
                category: "care",
                helpfulCount: 2567,
                authorName: "PlantScientist",
                isSeeded: true
            ),
            CommunityTip(
                plantName: "All Plants",
                tipTitle: "The chopstick test beats moisture meters",
                tipDescription: "Stick a wooden chopstick into the soil. Pull it out after 1 min. If it's damp/dark = don't water. If dry/clean = time to water. More reliable than any $20 moisture meter I've tried.",
                category: "watering",
                helpfulCount: 3012,
                authorName: "OldSchoolGardener",
                isSeeded: true
            ),
            CommunityTip(
                plantName: "All Plants",
                tipTitle: "Group your plants — humidity boost",
                tipDescription: "Clustering plants together creates a micro-humidity zone as they transpire. My calatheas and ferns stopped getting crispy tips once I moved them close together. Free humidifier!",
                category: "care",
                helpfulCount: 1345,
                authorName: "HumidityHack",
                isSeeded: true
            ),
        ]
    }
}
