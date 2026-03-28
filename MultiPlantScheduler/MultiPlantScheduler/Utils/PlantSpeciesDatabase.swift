import Foundation

/// A houseplant species with default care information
struct PlantSpecies: Identifiable {
    let id = UUID()
    let name: String
    let defaultWateringDays: Int
    let emoji: String

    init(_ name: String, wateringDays: Int, emoji: String) {
        self.name = name
        self.defaultWateringDays = wateringDays
        self.emoji = emoji
    }
}

/// Static database of 75+ common houseplants organized alphabetically
enum PlantSpeciesDatabase {
    static let database: [PlantSpecies] = [
        PlantSpecies("Alocasia", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Aloe Vera", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Anthurium", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Areca Palm", wateringDays: 5, emoji: "🌴"),
        PlantSpecies("Begonia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Bird of Paradise", wateringDays: 10, emoji: "🌺"),
        PlantSpecies("Boston Fern", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Bromeliad", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Cactus - Barrel", wateringDays: 21, emoji: "🌵"),
        PlantSpecies("Cactus - Christmas", wateringDays: 10, emoji: "🌵"),
        PlantSpecies("Calathea", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Caladium", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Carnivorous Plant", wateringDays: 3, emoji: "🪴"),
        PlantSpecies("Charm Palm", wateringDays: 5, emoji: "🌴"),
        PlantSpecies("Chinese Evergreen", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Chlorophytum - Spider Plant", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Clivia Miniata", wateringDays: 10, emoji: "🌺"),
        PlantSpecies("Coleus", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Coral Plant", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Crassula - Jade Plant", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Croton", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Cyclamen", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Cymbidium Orchid", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Daffodil", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Datura", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Delphinium", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Dieffenbachia", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Dill", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Dracaena", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Dracaena - Dragon Tree", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Easter Cactus", wateringDays: 7, emoji: "🌵"),
        PlantSpecies("Echeveria", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Epipremnum - Pothos", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Eryngium", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Eucalyptus", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Euphorbia Pulcherrima - Poinsettia", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Ferns - Maidenhair", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Ferns - Rabbit's Foot", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Ficus Benjamina", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Ficus Elastica - Rubber Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Ficus Lyrata - Fiddle Leaf Fig", wateringDays: 7, emoji: "🌳"),
        PlantSpecies("Fittonia", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Forget-Me-Not", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Freesia", wateringDays: 7, emoji: "🌼"),
        PlantSpecies("Gardenia", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Geranium", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Gerbera Daisy", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Gloxinia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Goldfish Plant", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Guzmania", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Gypsophila", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Haworthia", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Hedera - Ivy", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Hibiscus", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Hippeastrum", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Hoya - Wax Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Hydrangea", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Hypoestes", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Impatiens", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Ipomoea - Morning Glory", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Iris", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Jade Plant", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Jasmine", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Kalanchoe", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Lantana", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Lilium - Lily", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Lithops - Living Stones", wateringDays: 21, emoji: "🪴"),
        PlantSpecies("Maranta - Prayer Plant", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Monstera Deliciosa", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Narcissus - Daffodil", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Nerium - Oleander", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Nephrolepis - Boston Fern", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Orchid - Cattleya", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Dendrobium", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Moth", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Phalaenopsis", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Oxalis", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Peace Lily", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Pelargonium - Geranium", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Peperomia", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Philodendron", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Pilea Peperomioides - Chinese Money Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Pinaceae - Pine", wateringDays: 10, emoji: "🌳"),
        PlantSpecies("Platycerium - Staghorn Fern", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Plectranthus - Swedish Ivy", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Plumbago", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Poinsettia", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Raphidophora - Mini Monstera", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Rhaphidophora Tetrasperma", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Rhododendron", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Rhoeo", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Rosa - Rose", wateringDays: 5, emoji: "🌹"),
        PlantSpecies("Rosemary", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Ruellia", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Saintpaulia - African Violet", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Sansevieria - Snake Plant", wateringDays: 14, emoji: "🌱"),
        PlantSpecies("Saxifraga", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Scindapsus - Satin Pothos", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Schlumbergera - Christmas Cactus", wateringDays: 10, emoji: "🌵"),
        PlantSpecies("Schooner Palm", wateringDays: 5, emoji: "🌴"),
        PlantSpecies("Sedum", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Selaginella", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Senecio - String of Pearls", wateringDays: 14, emoji: "🌿"),
        PlantSpecies("Setcreasea - Purple Heart", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Shaflera", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Solanum", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Solenostemon - Coleus", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Spathiphyllum - Peace Lily", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Stapelia", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Stephanotis", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Streptocarpus - Cape Primrose", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Strobilanthes", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Syngonium", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Syzygium", wateringDays: 10, emoji: "🌳"),
        PlantSpecies("Tecoma", wateringDays: 10, emoji: "🌺"),
        PlantSpecies("Tetrastigma", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Thaumatococcus", wateringDays: 10, emoji: "🌴"),
        PlantSpecies("Thuja - Arborvitae", wateringDays: 10, emoji: "🌳"),
        PlantSpecies("Tibouchina", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Tibouchina Urvilleana", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Tillandsia - Air Plant", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Tolmiea", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Tradescantia", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Tripogandra", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Tulip", wateringDays: 5, emoji: "🌷"),
        PlantSpecies("Vallota", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Velvet Plant", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Verbena", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Veronica", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Vinca", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Viola", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Vriesea", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Walstera", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Washingtonia Palm", wateringDays: 5, emoji: "🌴"),
        PlantSpecies("Weeping Fig", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Whitfieldia", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Yucca", wateringDays: 14, emoji: "🌿"),
        PlantSpecies("Zamia", wateringDays: 14, emoji: "🌿"),
        PlantSpecies("Zamioculcas - ZZ Plant", wateringDays: 21, emoji: "🌿"),
        PlantSpecies("Zantedeschias", wateringDays: 10, emoji: "🌺"),
        PlantSpecies("Zebrina", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Zinnia", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Custom", wateringDays: 7, emoji: "🌱"),
    ]

    /// Search the plant species database by name (case-insensitive, partial match)
    /// - Parameter query: The search query
    /// - Returns: Array of matching plant species
    static func search(query: String) -> [PlantSpecies] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return database
        }
        let lowercaseQuery = query.lowercased()
        return database.filter { $0.name.lowercased().contains(lowercaseQuery) }
    }

    /// Get a specific plant species by exact name match
    /// - Parameter name: The exact name to find
    /// - Returns: The matching PlantSpecies, or nil if not found
    static func species(named name: String) -> PlantSpecies? {
        database.first { $0.name == name }
    }
}
