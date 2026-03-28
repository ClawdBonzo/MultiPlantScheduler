import SwiftUI
import PhotosUI
import SwiftData

struct AddPlantView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    var plantToEdit: Plant?

    @State private var name = ""
    @State private var species: PlantSpecies?
    @State private var wateringIntervalDays = 7
    @State private var room = "Living Room"
    @State private var notes = ""
    @State private var fertilizerType = ""
    @State private var enableSeasonalAdjust = true
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?

    @State private var speciesSearchText = ""

    let rooms = ["Living Room", "Bedroom", "Kitchen", "Bathroom", "Office", "Balcony", "Other"]

    var filteredSpecies: [PlantSpecies] {
        if speciesSearchText.isEmpty {
            return PlantSpeciesDatabase.database.prefix(10).map { $0 }
        }
        return PlantSpeciesDatabase.search(query: speciesSearchText)
    }

    var adjustedInterval: Int {
        enableSeasonalAdjust
            ? SeasonalAdjuster.adjustedInterval(baseInterval: wateringIntervalDays)
            : wateringIntervalDays
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                Form {
                    // Photo section
                    Section("Photo") {
                        VStack(spacing: 12) {
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                ZStack {
                                    if let photoData = photoData,
                                       let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(AppColors.limeGreen, lineWidth: 3)
                                            )
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            AppColors.forestGreen.opacity(0.6),
                                                            AppColors.limeGreen.opacity(0.4)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 120, height: 120)
                                                .overlay(
                                                    Circle()
                                                        .stroke(AppColors.limeGreen, lineWidth: 3)
                                                )

                                            VStack(spacing: 4) {
                                                Text("📸")
                                                    .font(.system(size: 28))

                                                Text("Add Photo")
                                                    .font(.system(.caption, design: .rounded))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(AppColors.textPrimary)
                                            }
                                        }
                                    }
                                }
                            }

                            if photoData != nil {
                                Button(role: .destructive) {
                                    withAnimation {
                                        photoData = nil
                                        selectedPhotoItem = nil
                                    }
                                } label: {
                                    Text("Remove Photo")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                    // Details section
                    Section("Details") {
                        TextField("Plant name", text: $name)
                            .font(.system(.body, design: .rounded))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Species (Optional)")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textSecondary)

                            SearchableSpeciesPicker(
                                species: $species,
                                searchText: $speciesSearchText,
                                filteredSpecies: filteredSpecies
                            )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Watering Interval")
                                    .font(.system(.body, design: .rounded))

                                Spacer()

                                Text("\(wateringIntervalDays) days")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.limeGreen)
                            }

                            Stepper(
                                "Adjust interval",
                                value: $wateringIntervalDays,
                                in: 1...60
                            )
                            .labelsHidden()
                        }

                        Picker("Room", selection: $room) {
                            ForEach(rooms, id: \.self) { room in
                                Text(room).tag(room)
                            }
                        }
                        .font(.system(.body, design: .rounded))
                    }
                    .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                    // Notes section
                    Section("Notes") {
                        TextField("Care tips, preferences...", text: $notes, axis: .vertical)
                            .font(.system(.body, design: .rounded))
                            .lineLimit(3...5)
                    }
                    .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                    // Fertilizer section
                    Section("Fertilizer") {
                        TextField("Fertilizer type (optional)", text: $fertilizerType)
                            .font(.system(.body, design: .rounded))
                    }
                    .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                    // Seasonal section
                    Section("Smart Watering") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(
                                isOn: $enableSeasonalAdjust
                            ) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Seasonal Auto-Adjust")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)

                                    Text("Adjust watering by season")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .font(.system(.body, design: .rounded))

                            if enableSeasonalAdjust {
                                HStack {
                                    Text("Adjusted Interval")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)

                                    Spacer()

                                    HStack(spacing: 4) {
                                        Text("\(wateringIntervalDays)d")
                                            .strikethrough()
                                            .foregroundColor(AppColors.textSecondary)

                                        Text("\(adjustedInterval)d")
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppColors.limeGreen)
                                    }
                                    .font(.system(.caption, design: .rounded))
                                }
                            }
                        }
                    }
                    .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(plantToEdit == nil ? "Add Plant" : "Edit Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(AppColors.limeGreen)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        savePlant()
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.limeGreen)
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.5)
                }
            }
            .onAppear {
                if let plant = plantToEdit {
                    name = plant.name
                    species = PlantSpeciesDatabase.database.first { $0.name == plant.species }
                    wateringIntervalDays = plant.wateringIntervalDays
                    room = plant.room ?? "Living Room"
                    notes = plant.notes ?? ""
                    fertilizerType = plant.fertilizerType ?? ""
                    if let photoData = plant.photoData {
                        self.photoData = photoData
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
    }

    private func savePlant() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        if let plantToEdit = plantToEdit {
            // Edit existing plant
            plantToEdit.name = name
            plantToEdit.species = species?.name
            plantToEdit.wateringIntervalDays = wateringIntervalDays
            plantToEdit.room = room
            plantToEdit.notes = notes
            plantToEdit.fertilizerType = fertilizerType
            if let photoData = photoData {
                plantToEdit.photoData = photoData
            }
        } else {
            // Create new plant
            let newPlant = Plant(
                name: name,
                species: species?.name,
                wateringIntervalDays: wateringIntervalDays,
                room: room,
                notes: notes.isEmpty ? nil : notes,
                fertilizerType: fertilizerType.isEmpty ? nil : fertilizerType,
                photoData: photoData
            )

            modelContext.insert(newPlant)

            // Schedule notification
            Task {
                await NotificationManager.shared.scheduleReminder(for: newPlant)
            }
        }

        try? modelContext.save()
        dismiss()
    }
}

struct SearchableSpeciesPicker: View {
    @Binding var species: PlantSpecies?
    @Binding var searchText: String
    let filteredSpecies: [PlantSpecies]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search species...", text: $searchText)
                .font(.system(.body, design: .rounded))
                .textFieldStyle(.roundedBorder)

            if !filteredSpecies.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(filteredSpecies, id: \.name) { spec in
                        Button(action: {
                            species = spec
                            searchText = ""
                        }) {
                            HStack {
                                Text(spec.emoji)
                                    .font(.system(size: 18))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(spec.name)
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text("\(spec.defaultWateringDays) day interval")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()
                            }
                            .padding(8)
                            .contentShape(Rectangle())
                        }
                    }
                }
                .background(Color(red: 0.08, green: 0.08, blue: 0.08))
                .cornerRadius(8)
            }

            if let selected = species {
                HStack {
                    Text(selected.emoji)
                        .font(.system(size: 16))

                    Text(selected.name)
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Button(action: {
                        species = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(8)
                .background(AppColors.forestGreen.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddPlantView()
            .environmentObject(RevenueCatManager.shared)
    }
}
