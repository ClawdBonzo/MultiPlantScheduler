import WidgetKit
import SwiftUI

/// Medium widget showing top 3 plants needing water
struct MediumPlantWidget: Widget {
    let kind: String = "MediumPlantWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.071, green: 0.071, blue: 0.071)
                }
        }
        .configurationDisplayName("Garden Overview")
        .description("See your top plants needing water")
        .supportedFamilies([.systemMedium])
    }
}

struct MediumWidgetView: View {
    let entry: PlantWidgetEntry

    var body: some View {
        if !entry.isPremium {
            HStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Widgets")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Upgrade to Premium to see your plants here")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            .padding()
        } else if entry.plants.isEmpty {
            HStack(spacing: 12) {
                Text("🌱")
                    .font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text("My Garden")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Add plants to see them here")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        } else {
            HStack(spacing: 0) {
                ForEach(Array(entry.plants.prefix(3))) { plant in
                    VStack(spacing: 6) {
                        Text(plant.emoji)
                            .font(.title2)

                        Text(plant.name)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(plant.statusText)
                            .font(.system(size: 9))
                            .fontWeight(.semibold)
                            .foregroundStyle(urgencyColor(plant.urgency))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(urgencyColor(plant.urgency).opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func urgencyColor(_ urgency: WidgetUrgency) -> Color {
        switch urgency {
        case .critical: return .red
        case .warning: return .yellow
        case .good: return Color(red: 0.133, green: 0.545, blue: 0.133)
        }
    }
}
