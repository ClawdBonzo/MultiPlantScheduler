import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(sort: \Plant.createdAt) var plants: [Plant]
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var revenueCatManager: RevenueCatManager

    @State private var showDeleteConfirmation = false
    @State private var showDeleteSecondConfirmation = false
    @State private var showNotificationError = false
    @State private var notificationsEnabled = false

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            Form {
                // Premium section
                Section("Premium") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(revenueCatManager.isPremium ? "✓ Premium Active" : "Free Plan")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(revenueCatManager.isPremium ? AppColors.limeGreen : AppColors.textPrimary)

                            Spacer()

                            if revenueCatManager.isPremium {
                                Text("Lifetime")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        if !revenueCatManager.isPremium {
                            Text("Upgrade to unlock unlimited plants and more")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                // Data section
                Section("Data") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Plant Count")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)

                            Text("\(plants.count) plant\(plants.count != 1 ? "s" : "")")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()
                    }

                    if !plants.isEmpty {
                        ShareLink(
                            item: generatePlantCSV(),
                            subject: Text("Plant Collection"),
                            message: Text("My plants from Multi Plant app"),
                            preview: SharePreview("Plant List")
                        ) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.limeGreen)

                                Text("Export All Plants as CSV")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                    }
                }
                .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                // Notifications section
                Section("Notifications") {
                    Toggle(
                        isOn: $notificationsEnabled
                    ) {
                        Text("Enable Reminders")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .tint(AppColors.limeGreen)
                    .onChange(of: notificationsEnabled) { _, isEnabled in
                        Task {
                            let permitted = await NotificationManager.shared.requestPermission()
                            if !permitted && isEnabled {
                                notificationsEnabled = false
                                showNotificationError = true
                            } else if permitted {
                                await NotificationManager.shared.rescheduleAllReminders(plants: plants)
                            }
                        }
                    }

                    Button(action: {
                        Task {
                            await NotificationManager.shared.rescheduleAllReminders(plants: plants)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.limeGreen)

                            Text("Reschedule All Reminders")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }
                .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                // App section
                Section("App") {
                    HStack {
                        Text("Version")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Text("v\(appVersion)")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Link(
                        destination: URL(string: "https://apps.apple.com/app/id6761313595")!
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.yellow)

                            Text("Rate on App Store")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/id6761313595")!,
                        subject: Text("Multi Plant Watering Schedule"),
                        message: Text("Check out this awesome plant care tracker!"),
                        preview: SharePreview("Multi Plant App", image: Image(systemName: "leaf.fill"))
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.limeGreen)

                            Text("Share with Friends")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                // Legal section
                Section("Legal") {
                    Button(action: { showDisclaimerAlert() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.limeGreen)

                            Text("Plant Care Disclaimer")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Link(
                        destination: URL(string: "https://github.com/ClawdBonzo/MultiPlantScheduler/blob/main/PRIVACY_POLICY.md")!
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.limeGreen)

                            Text("Privacy Policy")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                // Support section
                Section("Support") {
                    Link(
                        destination: URL(string: "mailto:support@multiplant.app?subject=Feedback")!
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.limeGreen)

                            Text("Send Feedback")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))

                // Danger zone
                Section("Danger Zone") {
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14, weight: .semibold))

                            Text("Delete All Data")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)

                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color(red: 0.118, green: 0.118, blue: 0.118))
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Delete All Data?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }

            Button("Review Items", role: .none) {
                showDeleteSecondConfirmation = true
            }
        } message: {
            Text("This will delete all \(plants.count) plants and their care history. This action cannot be undone.")
        }
        .alert("Delete Permanently?", isPresented: $showDeleteSecondConfirmation) {
            Button("Cancel", role: .cancel) { }

            Button("Delete All Data", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("Are you absolutely sure? This is permanent and cannot be recovered.")
        }
        .alert("Notification Permission Required", isPresented: $showNotificationError) {
            Button("OK") { }
        } message: {
            Text("Please enable notifications in Settings > Notifications to use this feature.")
        }
    }

    private func generatePlantCSV() -> URL {
        var csvContent = "Name,Species,Room,Watering Interval,Added Date,Care Logs\n"

        for plant in plants {
            let dateString = plant.createdAt.formatted(date: .abbreviated, time: .omitted)
            let species = plant.species?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            let room = plant.room?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""

            csvContent += "\"\(plant.name)\",\"\(species)\",\"\(room)\",\(plant.wateringIntervalDays),\"\(dateString)\",\(plant.careLogs.count)\n"
        }

        let fileName = "PlantCollection_\(Date.now.formatted(date: .abbreviated, time: .omitted)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try? csvContent.write(to: url, atomically: true, encoding: .utf8)

        return url
    }

    private func deleteAllData() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        for plant in plants {
            modelContext.delete(plant)
        }

        try? modelContext.save()

        Task {
            for plant in plants {
                await NotificationManager.shared.cancelReminder(for: plant)
            }
        }

        dismiss()
    }

    private func showDisclaimerAlert() {
        let alert = UIAlertController(
            title: "Plant Care Disclaimer",
            message: """
            Multi Plant Watering Schedule is a reminder and tracking tool designed to help you care for your plants. It is not a substitute for professional horticultural advice.

            Plant care needs vary based on:
            - Plant species
            - Local climate and weather
            - Light conditions
            - Soil type
            - Pot size and drainage
            - Season and humidity

            The watering reminders are suggestions only. Always check your plant's soil moisture before watering. Different plants have different needs. Consult care guides or a local nursery for specific plant care information.

            This app cannot be held responsible for plant health outcomes.
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(RevenueCatManager.shared)
    }
}
