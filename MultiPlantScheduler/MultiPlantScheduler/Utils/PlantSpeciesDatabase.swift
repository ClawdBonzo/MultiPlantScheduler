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

/// Static database of 250+ common houseplants organized alphabetically
enum PlantSpeciesDatabase {
    static let database: [PlantSpecies] = [
        // A
        PlantSpecies("Abutilon - Flowering Maple", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Acalypha - Chenille Plant", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Adiantum - Maidenhair Fern", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Aeonium", wateringDays: 10, emoji: "🪴"),
        PlantSpecies("Agave", wateringDays: 21, emoji: "🪴"),
        PlantSpecies("Aglaonema - Chinese Evergreen", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Alocasia - Elephant Ear", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Aloe Vera", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Alternanthera", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Amaryllis", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Ananas - Pineapple Plant", wateringDays: 7, emoji: "🍍"),
        PlantSpecies("Anthurium", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Aphelandra - Zebra Plant", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Araucaria - Norfolk Island Pine", wateringDays: 7, emoji: "🌲"),
        PlantSpecies("Areca Palm", wateringDays: 5, emoji: "🌴"),
        PlantSpecies("Asparagus Fern", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Aspidistra - Cast Iron Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Asplenium - Bird's Nest Fern", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Astrophytum - Star Cactus", wateringDays: 21, emoji: "🌵"),

        // B
        PlantSpecies("Bamboo Palm", wateringDays: 5, emoji: "🌴"),
        PlantSpecies("Basil", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Begonia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Begonia Rex", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Bird of Paradise", wateringDays: 10, emoji: "🌺"),
        PlantSpecies("Boston Fern", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Bougainvillea", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Bromeliad", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Burro's Tail", wateringDays: 14, emoji: "🪴"),

        // C
        PlantSpecies("Cactus - Barrel", wateringDays: 21, emoji: "🌵"),
        PlantSpecies("Cactus - Bunny Ears (Opuntia)", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Christmas", wateringDays: 10, emoji: "🌵"),
        PlantSpecies("Cactus - Column (Cereus)", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Easter", wateringDays: 7, emoji: "🌵"),
        PlantSpecies("Cactus - Fairy Castle", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Golden Barrel", wateringDays: 21, emoji: "🌵"),
        PlantSpecies("Cactus - Moon", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Old Lady", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Organ Pipe", wateringDays: 21, emoji: "🌵"),
        PlantSpecies("Cactus - Pincushion", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Prickly Pear (Opuntia)", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Saguaro", wateringDays: 28, emoji: "🌵"),
        PlantSpecies("Cactus - San Pedro", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Cactus - Star", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Caladium", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Calathea", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Calathea Orbifolia", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Calathea Rattlesnake", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Carnivorous Plant", wateringDays: 3, emoji: "🪴"),
        PlantSpecies("Cast Iron Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Celosia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Ceropegia - String of Hearts", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Chinese Money Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Chlorophytum - Spider Plant", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Christmas Cactus", wateringDays: 10, emoji: "🌵"),
        PlantSpecies("Chrysanthemum", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Cineraria", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Cissus - Grape Ivy", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Citrus Tree (Indoor)", wateringDays: 7, emoji: "🍋"),
        PlantSpecies("Clivia", wateringDays: 10, emoji: "🌺"),
        PlantSpecies("Codiaeum - Croton", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Coffee Plant", wateringDays: 5, emoji: "☕"),
        PlantSpecies("Coleus", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Columnea - Goldfish Plant", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Cordyline", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Crassula - Jade Plant", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Crossandra", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Croton", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Ctenanthe", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Cuphea", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Cyclamen", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Cymbidium Orchid", wateringDays: 7, emoji: "🌺"),

        // D
        PlantSpecies("Daffodil", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Dahlia", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Davallia - Rabbit's Foot Fern", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Dieffenbachia", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Dionaea - Venus Flytrap", wateringDays: 3, emoji: "🪴"),
        PlantSpecies("Dischidia", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Dracaena", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Dracaena - Dragon Tree", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Dracaena - Lucky Bamboo", wateringDays: 7, emoji: "🎋"),
        PlantSpecies("Drosera - Sundew", wateringDays: 3, emoji: "🪴"),
        PlantSpecies("Dudleya", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Dwarf Umbrella Tree", wateringDays: 7, emoji: "🌳"),

        // E
        PlantSpecies("Echeveria", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Elephant Bush (Portulacaria)", wateringDays: 10, emoji: "🪴"),
        PlantSpecies("Epipremnum - Pothos", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Episcia - Flame Violet", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Eucalyptus", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Euphorbia", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Euphorbia Tirucalli - Pencil Cactus", wateringDays: 14, emoji: "🪴"),

        // F
        PlantSpecies("Fatsia Japonica", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Fern - Asparagus", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Fern - Bird's Nest", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Fern - Boston", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Fern - Maidenhair", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Fern - Rabbit's Foot", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Fern - Staghorn", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Fern - Sword", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Ficus Audrey", wateringDays: 7, emoji: "🌳"),
        PlantSpecies("Ficus Benjamina", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Ficus Elastica - Rubber Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Ficus Lyrata - Fiddle Leaf Fig", wateringDays: 7, emoji: "🌳"),
        PlantSpecies("Ficus Tineke", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Fittonia - Nerve Plant", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Freesia", wateringDays: 7, emoji: "🌼"),
        PlantSpecies("Fuchsia", wateringDays: 5, emoji: "🌺"),

        // G
        PlantSpecies("Gardenia", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Gasteria", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Geranium", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Gerbera Daisy", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Gloxinia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Graptopetalum", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Graptoveria", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Guzmania", wateringDays: 5, emoji: "🌺"),

        // H
        PlantSpecies("Haworthia", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Hedera - English Ivy", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Heliconia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Hens and Chicks (Sempervivum)", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Herbs - Basil", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Herbs - Cilantro", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Herbs - Lavender", wateringDays: 7, emoji: "💜"),
        PlantSpecies("Herbs - Mint", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Herbs - Oregano", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Herbs - Parsley", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Herbs - Rosemary", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Herbs - Thyme", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Hibiscus", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Hippeastrum", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Hoya - Wax Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Hoya Kerrii - Sweetheart Plant", wateringDays: 14, emoji: "💚"),
        PlantSpecies("Hyacinth", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Hydrangea", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Hypoestes - Polka Dot Plant", wateringDays: 5, emoji: "🌿"),

        // I-J
        PlantSpecies("Impatiens", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Ipomoea - Morning Glory", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Iris", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Jade Plant", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Jasmine", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Juncus - Corkscrew Rush", wateringDays: 3, emoji: "🌿"),

        // K
        PlantSpecies("Kalanchoe", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Kentia Palm", wateringDays: 7, emoji: "🌴"),

        // L
        PlantSpecies("Lantana", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Lavender", wateringDays: 7, emoji: "💜"),
        PlantSpecies("Lemon Tree", wateringDays: 7, emoji: "🍋"),
        PlantSpecies("Lilium - Lily", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Lipstick Plant", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Lithops - Living Stones", wateringDays: 21, emoji: "🪴"),

        // M
        PlantSpecies("Mammillaria Cactus", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Mandevilla", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Maranta - Prayer Plant", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Medinilla", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Mimosa Pudica - Sensitive Plant", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Money Tree (Pachira)", wateringDays: 10, emoji: "🌳"),
        PlantSpecies("Monstera Adansonii", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Monstera Deliciosa", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Moses in the Cradle", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Musa - Banana Plant", wateringDays: 5, emoji: "🍌"),

        // N
        PlantSpecies("Narcissus - Daffodil", wateringDays: 5, emoji: "🌼"),
        PlantSpecies("Neanthe Bella Palm", wateringDays: 7, emoji: "🌴"),
        PlantSpecies("Nepenthes - Pitcher Plant", wateringDays: 3, emoji: "🪴"),
        PlantSpecies("Nephrolepis - Boston Fern", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Nerve Plant (Fittonia)", wateringDays: 5, emoji: "🌿"),

        // O
        PlantSpecies("Olive Tree (Indoor)", wateringDays: 10, emoji: "🫒"),
        PlantSpecies("Opuntia - Bunny Ears Cactus", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Opuntia - Prickly Pear", wateringDays: 14, emoji: "🌵"),
        PlantSpecies("Orchid - Cattleya", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Cymbidium", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Dendrobium", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Oncidium", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Phalaenopsis", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Orchid - Vanda", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Oxalis - Shamrock Plant", wateringDays: 5, emoji: "🍀"),

        // P
        PlantSpecies("Pachira - Money Tree", wateringDays: 10, emoji: "🌳"),
        PlantSpecies("Pachyphytum", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Panda Plant (Kalanchoe)", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Parlor Palm", wateringDays: 7, emoji: "🌴"),
        PlantSpecies("Passionflower", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Peace Lily", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Peperomia", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Peperomia Watermelon", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Periwinkle", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Petunia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Philodendron", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Philodendron Birkin", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Philodendron Brasil", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Philodendron Heartleaf", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Philodendron Pink Princess", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Pilea Peperomioides - Chinese Money Plant", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Platycerium - Staghorn Fern", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Plectranthus - Swedish Ivy", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Plumeria - Frangipani", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Poinsettia", wateringDays: 7, emoji: "🌺"),
        PlantSpecies("Polka Dot Plant", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Polyscias - Ming Aralia", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Ponytail Palm", wateringDays: 14, emoji: "🌴"),
        PlantSpecies("Pothos - Golden", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Pothos - Marble Queen", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Pothos - Neon", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Prayer Plant", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Primrose", wateringDays: 5, emoji: "🌸"),

        // R
        PlantSpecies("Raphidophora - Mini Monstera", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Rex Begonia", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Rhapis - Lady Palm", wateringDays: 7, emoji: "🌴"),
        PlantSpecies("Rhipsalis", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Rhododendron", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Rosa - Rose", wateringDays: 5, emoji: "🌹"),
        PlantSpecies("Rubber Plant", wateringDays: 10, emoji: "🌿"),

        // S
        PlantSpecies("Sago Palm", wateringDays: 10, emoji: "🌴"),
        PlantSpecies("Saintpaulia - African Violet", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Sansevieria - Snake Plant", wateringDays: 14, emoji: "🌱"),
        PlantSpecies("Sansevieria Cylindrica", wateringDays: 14, emoji: "🌱"),
        PlantSpecies("Satin Pothos (Scindapsus)", wateringDays: 10, emoji: "🌿"),
        PlantSpecies("Schefflera", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Schlumbergera - Christmas Cactus", wateringDays: 10, emoji: "🌵"),
        PlantSpecies("Sedum", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Selaginella - Spikemoss", wateringDays: 3, emoji: "🌿"),
        PlantSpecies("Senecio - String of Bananas", wateringDays: 14, emoji: "🌿"),
        PlantSpecies("Senecio - String of Dolphins", wateringDays: 14, emoji: "🌿"),
        PlantSpecies("Senecio - String of Pearls", wateringDays: 14, emoji: "🌿"),
        PlantSpecies("Shamrock Plant", wateringDays: 5, emoji: "🍀"),
        PlantSpecies("Snake Plant", wateringDays: 14, emoji: "🌱"),
        PlantSpecies("Spathiphyllum - Peace Lily", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Spider Plant", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Stapelia", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Stephanotis", wateringDays: 7, emoji: "🌸"),
        PlantSpecies("Streptocarpus - Cape Primrose", wateringDays: 5, emoji: "🌺"),
        PlantSpecies("Stromanthe Triostar", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Succulent - Assorted", wateringDays: 14, emoji: "🪴"),
        PlantSpecies("Syngonium - Arrowhead Plant", wateringDays: 7, emoji: "🌿"),

        // T
        PlantSpecies("Tillandsia - Air Plant", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Tradescantia", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Tradescantia Nanouk", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Tradescantia Zebrina", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Tulip", wateringDays: 5, emoji: "🌷"),

        // V
        PlantSpecies("Velvet Plant (Gynura)", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Venus Flytrap", wateringDays: 3, emoji: "🪴"),
        PlantSpecies("Vriesea", wateringDays: 5, emoji: "🌺"),

        // W
        PlantSpecies("Wandering Jew", wateringDays: 7, emoji: "🌿"),
        PlantSpecies("Washingtonia Palm", wateringDays: 5, emoji: "🌴"),
        PlantSpecies("Weeping Fig", wateringDays: 7, emoji: "🌿"),

        // Y-Z
        PlantSpecies("Yucca", wateringDays: 14, emoji: "🌿"),
        PlantSpecies("Zamioculcas - ZZ Plant", wateringDays: 21, emoji: "🌿"),
        PlantSpecies("Zantedeschia - Calla Lily", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Zebra Plant (Aphelandra)", wateringDays: 5, emoji: "🌿"),
        PlantSpecies("Zinnia", wateringDays: 5, emoji: "🌸"),
        PlantSpecies("Custom", wateringDays: 7, emoji: "🌱"),
    ]

    /// Search the plant species database by name (case-insensitive, partial match)
    static func search(query: String) -> [PlantSpecies] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return database
        }
        let lowercaseQuery = query.lowercased()
        return database.filter { $0.name.lowercased().contains(lowercaseQuery) }
    }

    /// Get a specific plant species by exact name match
    static func species(named name: String) -> PlantSpecies? {
        database.first { $0.name == name }
    }
}
