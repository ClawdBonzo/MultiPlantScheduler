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
    @State private var aiSuggestions: [PlantIdentifierService.Suggestion] = []

    // Scanning animation state
    @State private var scanProgress: CGFloat = 0
    @State private var scanPulse = false
    @State private var leafRotation: Double = 0
    @State private var radarRotation: Double = 0
    @State private var showScanOverlay = false
    @State private var showAIResult = false
    @State private var formFieldsOpacity: Double = 1.0
    @State private var dotCount = 0

    // Photo source
    @State private var showPhotoActionSheet = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false

    // Cloud ID state
    @State private var isCloudIdentifying = false
    @State private var cloudIDUsed = false
    @State private var showUpgradeForCloud = false

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
            return Array(PlantSpeciesDatabase.database.prefix(20))
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
                                            // Pulsing green tint overlay
                                            Circle()
                                                .fill(AppColors.limeGreen.opacity(scanPulse ? 0.22 : 0.10))
                                                .frame(width: 140, height: 140)

                                            // Fast radar sweep gradient
                                            Circle()
                                                .fill(
                                                    AngularGradient(
                                                        gradient: Gradient(colors: [
                                                            AppColors.limeGreen.opacity(0.0),
                                                            AppColors.limeGreen.opacity(0.0),
                                                            AppColors.limeGreen.opacity(0.0),
                                                            AppColors.limeGreen.opacity(0.35)
                                                        ]),
                                                        center: .center
                                                    )
                                                )
                                                .frame(width: 140, height: 140)
                                                .rotationEffect(.degrees(radarRotation))

                                            // Thick glowing progress ring
                                            Circle()
                                                .trim(from: 0, to: scanProgress)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [AppColors.limeGreen.opacity(0.2), AppColors.limeGreen],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ),
                                                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                                                )
                                                .frame(width: 154, height: 154)
                                                .rotationEffect(.degrees(-90))
                                                .shadow(color: AppColors.limeGreen.opacity(0.8), radius: scanPulse ? 14 : 6)

                                            // Pulsing outer glow ring 1
                                            Circle()
                                                .stroke(AppColors.limeGreen.opacity(scanPulse ? 0.45 : 0.1), lineWidth: 2)
                                                .frame(width: 170, height: 170)
                                                .scaleEffect(scanPulse ? 1.08 : 1.0)

                                            // Pulsing outer glow ring 2
                                            Circle()
                                                .stroke(AppColors.limeGreen.opacity(scanPulse ? 0.2 : 0.04), lineWidth: 1.5)
                                                .frame(width: 190, height: 190)
                                                .scaleEffect(scanPulse ? 1.06 : 0.96)

                                            // Orbiting leaf icons — larger, with spin
                                            ForEach(0..<4, id: \.self) { index in
                                                Image(systemName: "leaf.fill")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(AppColors.limeGreen)
                                                    .shadow(color: AppColors.limeGreen.opacity(0.7), radius: 6)
                                                    .rotationEffect(.degrees(leafRotation * 2))
                                                    .offset(y: -92)
                                                    .rotationEffect(.degrees(leafRotation + Double(index) * 90))
                                            }

                                            // Center analyzing text with pulsing dots + scale
                                            VStack(spacing: 4) {
                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 22, weight: .semibold))
                                                    .foregroundStyle(AppColors.limeGreen)
                                                    .opacity(scanPulse ? 1 : 0.4)
                                                    .scaleEffect(scanPulse ? 1.15 : 0.85)
                                                    .shadow(color: AppColors.limeGreen.opacity(0.6), radius: 8)

                                                Text("Analyzing\nwith AI\(String(repeating: ".", count: dotCount))")
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .foregroundStyle(.white)
                                                    .multilineTextAlignment(.center)
                                                    .scaleEffect(scanPulse ? 1.04 : 0.96)
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
                            if showAIResult, let confidence = aiConfidence {
                                VStack(spacing: 8) {
                                    // Top result
                                    if let speciesName = aiSpeciesName {
                                        HStack(spacing: 6) {
                                            Image(systemName: confidence >= 0.80 ? "checkmark.circle.fill" : "questionmark.circle.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(confidence >= 0.80 ? AppColors.limeGreen : .yellow)

                                            Text("\(Int(confidence * 100))% \(speciesName)")
                                                .font(.system(.caption, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(AppColors.textPrimary)
                                                .lineLimit(1)

                                            if confidence < 0.80 {
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
                                            (confidence >= 0.80 ? AppColors.limeGreen : Color.yellow).opacity(0.12)
                                        )
                                        .clipShape(Capsule())
                                    }

                                    // Alternative suggestions (show when low confidence)
                                    if confidence < 0.80 && aiSuggestions.count > 1 {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Not right? Tap to select:")
                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                .foregroundColor(AppColors.textSecondary)

                                            ForEach(aiSuggestions.dropFirst().prefix(2)) { suggestion in
                                                HStack(spacing: 6) {
                                                    Image(systemName: "leaf.fill")
                                                        .font(.system(size: 10))
                                                        .foregroundStyle(AppColors.limeGreen.opacity(0.6))

                                                    Text(suggestion.species)
                                                        .font(.system(.caption, design: .rounded))
                                                        .fontWeight(.medium)
                                                        .foregroundColor(AppColors.textPrimary)

                                                    Text("\(Int(suggestion.confidence * 100))%")
                                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                                        .foregroundColor(AppColors.textSecondary)

                                                    Spacer()
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.white.opacity(0.05))
                                                .cornerRadius(6)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    selectAISuggestion(suggestion)
                                                }
                                            }

                                            // "None of these" option
                                            HStack(spacing: 6) {
                                                Image(systemName: "xmark.circle")
                                                    .font(.system(size: 10))
                                                    .foregroundStyle(.red.opacity(0.6))

                                                Text("None of these — I'll pick manually")
                                                    .font(.system(.caption, design: .rounded))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(AppColors.textSecondary)

                                                Spacer()
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.03))
                                            .cornerRadius(6)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                clearAISuggestions()
                                            }
                                        }
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                            }

                            // "Get Precise ID" cloud button
                            if photoData != nil && showAIResult && !isIdentifying && !isCloudIdentifying && !cloudIDUsed {
                                Button {
                                    getPreciseCloudID()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "icloud.and.arrow.up")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Get Precise ID")
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.bold)

                                        Spacer()

                                        let credits = CloudIdentificationManager.shared.creditsRemaining
                                        let isPremium = revenueCatManager.isPremium
                                        if isPremium {
                                            Text("Unlimited")
                                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                                .foregroundStyle(AppColors.limeGreen)
                                        } else {
                                            Text("\(credits)/\(CloudIdentificationManager.maxFreeCredits) free")
                                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                                .foregroundStyle(credits > 0 ? AppColors.textSecondary : .yellow)
                                        }
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        LinearGradient(
                                            colors: [AppColors.forestGreen, AppColors.limeGreen.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .transition(.scale.combined(with: .opacity))
                            }

                            // Cloud identifying spinner
                            if isCloudIdentifying {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .tint(AppColors.limeGreen)
                                        .scaleEffect(0.8)
                                    Text("Getting precise ID...")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(.vertical, 4)
                                .transition(.opacity)
                            }

                            if photoData != nil && !isIdentifying && !isCloudIdentifying {
                                Button(role: .destructive) {
                                    withAnimation {
                                        photoData = nil
                                        selectedPhotoItem = nil
                                        aiConfidence = nil
                                        aiSpeciesName = nil
                                        aiSuggestions = []
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
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        // Compress to JPEG <1MB regardless of source format (HEIC, PNG, etc.)
                        let compressed = uiImage.jpegData(compressionQuality: 0.7)
                        photoData = compressed ?? data
                        startScanningAnimation(photoData: photoData!)
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
            .alert("Cloud IDs Used", isPresented: $showUpgradeForCloud) {
                Button("Maybe Later", role: .cancel) {}
            } message: {
                Text("You've used all 10 free cloud identifications. Upgrade to Premium for unlimited precise plant IDs.")
            }
        }
    }

    // MARK: - Scanning Animation

    private func startScanningAnimation(photoData: Data) {
        // Reset state
        showAIResult = false
        cloudIDUsed = false
        scanProgress = 0
        scanPulse = false
        leafRotation = 0
        radarRotation = 0
        dotCount = 0
        formFieldsOpacity = 0.5

        withAnimation(.easeIn(duration: 0.3)) {
            showScanOverlay = true
            isIdentifying = true
        }

        // Start pulsing glow — faster, more noticeable
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            scanPulse = true
        }

        // Start leaf orbit — faster
        withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
            leafRotation = 360
        }

        // Radar sweep rotation — fast 1.2s
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
            radarRotation = 360
        }

        // Animate progress ring
        withAnimation(.easeInOut(duration: 1.8)) {
            scanProgress = 0.85
        }

        // Pulsing dots animation
        startDotAnimation()

        // Haptic: light tap on scan start
        let startImpact = UIImpactFeedbackGenerator(style: .light)
        startImpact.impactOccurred()

        // Run actual AI identification in background
        Task {
            guard let uiImage = UIImage(data: photoData) else { return }
            let result = await PlantIdentifierService.shared.identifyPlant(from: uiImage)

            // Ensure minimum 2.0s of animation for the "a-ha" feel
            try? await Task.sleep(for: .milliseconds(600))

            await MainActor.run {
                // Complete the ring
                withAnimation(.easeOut(duration: 0.3)) {
                    scanProgress = 1.0
                }

                // Process AI result
                aiSuggestions = result.topSuggestions

                if let matchedSpecies = result.species {
                    aiConfidence = result.confidence
                    aiSpeciesName = matchedSpecies

                    // Only auto-fill name and species when confidence is high
                    if result.confidence >= 0.80 {
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
                    }
                    // Low confidence: show suggestions but don't auto-fill
                } else if result.confidence > 0 {
                    aiConfidence = result.confidence
                    aiSpeciesName = "Unknown plant"
                }

                // Dismiss overlay, show result with spring pop
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                        showScanOverlay = false
                        scanPulse = false
                        isIdentifying = false
                        showAIResult = true
                        formFieldsOpacity = 1.0
                    }

                    // Success haptic
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.success)
                }
            }
        }
    }

    private func startDotAnimation() {
        guard isIdentifying else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard self.isIdentifying else { return }
            self.dotCount = (self.dotCount % 3) + 1
            self.startDotAnimation()
        }
    }

    // MARK: - Cloud Precise ID

    private func getPreciseCloudID() {
        let isPremium = revenueCatManager.isPremium
        let cloud = CloudIdentificationManager.shared

        #if DEBUG
        print("☁️ AddPlant — 'Get Precise ID' tapped")
        #endif

        guard cloud.canUseCloud(isPremium: isPremium) else {
            showUpgradeForCloud = true
            return
        }

        guard let data = photoData, let uiImage = UIImage(data: data) else { return }

        withAnimation { isCloudIdentifying = true }

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        Task {
            if let cloudResult = await cloud.identifyPlant(from: uiImage, isPremium: isPremium) {
                let result = cloud.toIdentificationResult(cloudResult)

                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isCloudIdentifying = false
                        cloudIDUsed = true

                        aiConfidence = result.confidence
                        aiSpeciesName = result.species
                        aiSuggestions = result.topSuggestions

                        #if DEBUG
                        print("☁️ AddPlant — cloud result: \(result.species ?? "nil") @ \(Int(result.confidence * 100))%")
                        print("☁️ AddPlant — credits after call: \(CloudIdentificationManager.shared.creditsRemaining)")
                        #endif

                        // Cloud results are high quality — auto-fill
                        if let matchedSpecies = result.species {
                            if let dbSpecies = PlantSpeciesDatabase.species(named: matchedSpecies) {
                                species = dbSpecies
                                wateringIntervalDays = dbSpecies.defaultWateringDays
                                if name.isEmpty {
                                    let shortName = matchedSpecies.components(separatedBy: " - ").last ?? matchedSpecies
                                    name = shortName
                                }
                            } else {
                                if name.isEmpty { name = matchedSpecies }
                                wateringIntervalDays = result.defaultInterval
                            }
                        }
                    }

                    let success = UINotificationFeedbackGenerator()
                    success.notificationOccurred(.success)
                }
            } else {
                await MainActor.run {
                    withAnimation { isCloudIdentifying = false }
                    #if DEBUG
                    print("☁️ AddPlant — cloud call failed: \(cloud.lastErrorMessage ?? "unknown")")
                    #endif
                    // Key not configured — on-device result stays, no disruptive error
                }
            }
        }
    }

    // MARK: - AI Suggestion Helpers

    private func selectAISuggestion(_ suggestion: PlantIdentifierService.Suggestion) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            aiSpeciesName = suggestion.species
            aiConfidence = suggestion.confidence
            aiSuggestions = []

            if let dbSpecies = PlantSpeciesDatabase.species(named: suggestion.species) {
                species = dbSpecies
                wateringIntervalDays = dbSpecies.defaultWateringDays
                if name.isEmpty {
                    let shortName = suggestion.species.components(separatedBy: " - ").last ?? suggestion.species
                    name = shortName
                }
            } else {
                if name.isEmpty {
                    name = suggestion.species
                }
                wateringIntervalDays = suggestion.defaultInterval
            }
        }

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func clearAISuggestions() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            aiSuggestions = []
            aiConfidence = nil
            aiSpeciesName = nil
            showAIResult = false
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
            // Selected species chip
            if let selected = species {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.limeGreen)

                    Text(selected.name)
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("\(selected.defaultWateringDays)d watering")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textSecondary)
                        .onTapGesture {
                            species = nil
                        }
                }
                .padding(8)
                .background(AppColors.forestGreen.opacity(0.2))
                .cornerRadius(8)
            }

            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)

                TextField("Search \(PlantSpeciesDatabase.database.count) species...", text: $searchText)
                    .font(.system(.body, design: .rounded))

                if !searchText.isEmpty {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .onTapGesture {
                            searchText = ""
                        }
                }
            }
            .padding(8)
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(8)

            // Results list
            if !filteredSpecies.isEmpty && species == nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if searchText.isEmpty {
                            Text("Popular species")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.top, 4)
                                .padding(.bottom, 2)
                        } else {
                            Text("\(filteredSpecies.count) result\(filteredSpecies.count != 1 ? "s" : "")")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.top, 4)
                                .padding(.bottom, 2)
                        }

                        ForEach(filteredSpecies, id: \.name) { spec in
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

                                    Text("Water every \(spec.defaultWateringDays) days")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                species = spec
                                searchText = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }

                            if spec.name != filteredSpecies.last?.name {
                                Divider()
                                    .background(Color.white.opacity(0.05))
                                    .padding(.leading, 40)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color(red: 0.08, green: 0.08, blue: 0.08))
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
