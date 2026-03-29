import SwiftUI
import PhotosUI
import SwiftData

struct AddPlantView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    var plantToEdit: Plant?
    var isFromOnboarding: Bool = false
    var openCameraOnAppear: Bool = false
    @Binding var showCelebratory: Bool

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

    // AI identification state
    @State private var isIdentifying = false
    @State private var aiConfidence: Double?
    @State private var aiSpeciesName: String?

    // Scanning animation state
    @State private var scanProgress: CGFloat = 0
    @State private var scanPulse = false
    @State private var leafRotation: Double = 0
    @State private var showScanOverlay = false
    @State private var showAIResult = false
    @State private var formFieldsOpacity: Double = 1.0

    // Photo source
    @State private var showPhotoActionSheet = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false

    // Save state
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    let rooms = ["Living Room", "Bedroom", "Kitchen", "Bathroom", "Office", "Balcony", "Other"]

    init(plantToEdit: Plant? = nil, isFromOnboarding: Bool = false, openCameraOnAppear: Bool = false, showCelebratory: Binding<Bool> = .constant(false)) {
        self.plantToEdit = plantToEdit
        self.isFromOnboarding = isFromOnboarding
        self.openCameraOnAppear = openCameraOnAppear
        self._showCelebratory = showCelebratory
    }

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
                            // Tappable circular photo area with scanning animation
                            ZStack {
                                if let photoData = photoData,
                                   let uiImage = UIImage(data: photoData) {
                                    ZStack {
                                        // Photo circle
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 140, height: 140)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(AppColors.limeGreen.opacity(showScanOverlay ? 0.3 : 1), lineWidth: 3)
                                            )

                                        // Scanning overlay
                                        if showScanOverlay {
                                            // Green tint overlay
                                            Circle()
                                                .fill(AppColors.limeGreen.opacity(0.2))
                                                .frame(width: 140, height: 140)

                                            // Animated progress ring
                                            Circle()
                                                .trim(from: 0, to: scanProgress)
                                                .stroke(
                                                    AppColors.limeGreen,
                                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                                )
                                                .frame(width: 152, height: 152)
                                                .rotationEffect(.degrees(-90))
                                                .shadow(color: AppColors.limeGreen.opacity(0.6), radius: scanPulse ? 8 : 3)

                                            // Pulsing outer glow ring
                                            Circle()
                                                .stroke(AppColors.limeGreen.opacity(scanPulse ? 0.4 : 0.1), lineWidth: 2)
                                                .frame(width: 164, height: 164)
                                                .scaleEffect(scanPulse ? 1.05 : 1.0)

                                            // Orbiting leaf icons
                                            ForEach(0..<3, id: \.self) { index in
                                                Image(systemName: "leaf.fill")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundStyle(AppColors.limeGreen)
                                                    .offset(y: -88)
                                                    .rotationEffect(.degrees(leafRotation + Double(index) * 120))
                                            }

                                            // Center analyzing text
                                            VStack(spacing: 4) {
                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundStyle(AppColors.limeGreen)
                                                    .opacity(scanPulse ? 1 : 0.6)

                                                Text("Analyzing\nwith AI...")
                                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .multilineTextAlignment(.center)
                                            }
                                        }

                                        // AI badge (shown after scan completes)
                                        if aiConfidence != nil && !showScanOverlay {
                                            HStack(spacing: 3) {
                                                Image(systemName: "brain")
                                                    .font(.system(size: 8, weight: .bold))
                                                Text("AI")
                                                    .font(.system(size: 9, weight: .bold))
                                            }
                                            .foregroundStyle(.black)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(AppColors.limeGreen)
                                            .clipShape(Capsule())
                                            .offset(x: 50, y: -55)
                                            .transition(.scale.combined(with: .opacity))
                                        }
                                    }
                                    .onTapGesture {
                                        if !isIdentifying {
                                            showPhotoActionSheet = true
                                        }
                                    }
                                } else {
                                    // Empty photo placeholder — tappable
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
                                            .frame(width: 140, height: 140)
                                            .overlay(
                                                Circle()
                                                    .stroke(AppColors.limeGreen, lineWidth: 3)
                                            )

                                        VStack(spacing: 6) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white.opacity(0.8))

                                            Text("Tap to Add Photo")
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                .foregroundColor(AppColors.textPrimary)
                                        }
                                    }
                                    .onTapGesture {
                                        showPhotoActionSheet = true
                                    }
                                }
                            }
                            .frame(height: 170)

                            // AI result banner (appears after scan)
                            if showAIResult, let confidence = aiConfidence, let speciesName = aiSpeciesName {
                                HStack(spacing: 6) {
                                    Image(systemName: confidence >= 0.70 ? "checkmark.circle.fill" : "questionmark.circle.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(confidence >= 0.70 ? AppColors.limeGreen : .yellow)

                                    Text("\(Int(confidence * 100))% \(speciesName)")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                        .lineLimit(1)

                                    if confidence < 0.70 {
                                        Text("Best guess")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(.black)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color.yellow)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    (confidence >= 0.70 ? AppColors.limeGreen : Color.yellow).opacity(0.12)
                                )
                                .clipShape(Capsule())
                                .transition(.scale.combined(with: .opacity))
                            }

                            if photoData != nil && !isIdentifying {
                                Button(role: .destructive) {
                                    withAnimation {
                                        photoData = nil
                                        selectedPhotoItem = nil
                                        aiConfidence = nil
                                        aiSpeciesName = nil
                                        showAIResult = false
                                        showScanOverlay = false
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
                            .opacity(formFieldsOpacity)

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
                    .disabled(!isFormValid || isIdentifying)
                    .opacity(isFormValid && !isIdentifying ? 1 : 0.5)
                }
            }
            .confirmationDialog("Add Plant Photo", isPresented: $showPhotoActionSheet, titleVisibility: .visible) {
                Button("Take Photo") {
                    showCamera = true
                }
                Button("Choose from Library") {
                    showPhotoPicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { image in
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        photoData = data
                        startScanningAnimation(photoData: data)
                    }
                }
                .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                        startScanningAnimation(photoData: data)
                    }
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
                    if let confidence = plant.aiConfidence {
                        aiConfidence = confidence
                        aiSpeciesName = plant.species
                        showAIResult = true
                    }
                } else if openCameraOnAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCamera = true
                    }
                } else if isFromOnboarding {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showPhotoActionSheet = true
                    }
                }
            }
            .alert("Save Failed", isPresented: $showSaveError) {
                Button("OK") {}
            } message: {
                Text(saveErrorMessage)
            }
        }
    }

    // MARK: - Scanning Animation

    private func startScanningAnimation(photoData: Data) {
        // Reset state
        showAIResult = false
        scanProgress = 0
        scanPulse = false
        leafRotation = 0
        formFieldsOpacity = 0.5

        withAnimation(.easeIn(duration: 0.3)) {
            showScanOverlay = true
            isIdentifying = true
        }

        // Start pulsing
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            scanPulse = true
        }

        // Start leaf rotation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            leafRotation = 360
        }

        // Animate progress ring
        withAnimation(.easeInOut(duration: 1.6)) {
            scanProgress = 0.85
        }

        // Run actual AI identification in background
        Task {
            guard let uiImage = UIImage(data: photoData) else { return }
            let result = await PlantIdentifierService.shared.identifyPlant(from: uiImage)

            // Ensure minimum 1.8s of animation for the "a-ha" feel
            try? await Task.sleep(for: .milliseconds(400))

            await MainActor.run {
                // Complete the ring
                withAnimation(.easeOut(duration: 0.3)) {
                    scanProgress = 1.0
                }

                // Process AI result
                if let matchedSpecies = result.species {
                    aiConfidence = result.confidence
                    aiSpeciesName = matchedSpecies

                    if let dbSpecies = PlantSpeciesDatabase.species(named: matchedSpecies) {
                        species = dbSpecies
                        wateringIntervalDays = dbSpecies.defaultWateringDays
                        if name.isEmpty {
                            let shortName = matchedSpecies.components(separatedBy: " - ").last ?? matchedSpecies
                            name = shortName
                        }
                    } else {
                        if name.isEmpty {
                            name = matchedSpecies
                        }
                        wateringIntervalDays = result.defaultInterval
                    }
                } else if result.confidence > 0 {
                    aiConfidence = result.confidence
                    aiSpeciesName = "Unknown plant"
                }

                // Dismiss overlay, show result
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showScanOverlay = false
                        scanPulse = false
                        isIdentifying = false
                        showAIResult = true
                        formFieldsOpacity = 1.0
                    }

                    // Haptic feedback
                    let impact = UINotificationFeedbackGenerator()
                    impact.notificationOccurred(.success)
                }
            }
        }
    }

    // MARK: - Save

    private func savePlant() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        do {
            if let plantToEdit = plantToEdit {
                plantToEdit.name = name
                plantToEdit.species = species?.name
                plantToEdit.wateringIntervalDays = wateringIntervalDays
                plantToEdit.room = room
                plantToEdit.notes = notes
                plantToEdit.fertilizerType = fertilizerType
                if let photoData = photoData {
                    plantToEdit.photoData = photoData
                }
                if let confidence = aiConfidence {
                    plantToEdit.aiConfidence = confidence
                    plantToEdit.lastIdentifiedDate = Date.now
                }
            } else {
                let newPlant = Plant(
                    name: name,
                    species: species?.name,
                    wateringIntervalDays: wateringIntervalDays,
                    room: room,
                    notes: notes.isEmpty ? nil : notes,
                    fertilizerType: fertilizerType.isEmpty ? nil : fertilizerType,
                    photoData: photoData
                )
                if let confidence = aiConfidence {
                    newPlant.aiConfidence = confidence
                    newPlant.lastIdentifiedDate = Date.now
                }

                modelContext.insert(newPlant)

                Task {
                    await NotificationManager.shared.scheduleReminder(for: newPlant)
                }
            }

            try modelContext.save()

            if isFromOnboarding && plantToEdit == nil {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showCelebratory = true
                }
            } else {
                dismiss()
            }
        } catch {
            saveErrorMessage = error.localizedDescription
            showSaveError = true
        }
    }
}

// MARK: - Camera Picker (UIImagePickerController wrapper)

struct CameraPickerView: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Species Picker

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
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.limeGreen)
                                    .frame(width: 24)

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
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.limeGreen)

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
