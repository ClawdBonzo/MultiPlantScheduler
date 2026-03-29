import WidgetKit
import SwiftUI

/// Small widget showing the most urgent plant
struct SmallPlantWidget: Widget {
    let kind: String = "SmallPlantWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.071, green: 0.071, blue: 0.071)
                }
        }
        .configurationDisplayName("Plant Status")
        .description("See your most urgent plant at a glance")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallWidgetView: View {
    let entry: PlantWidgetEntry

    var body: some View {
        if !entry.isPremium {
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Text("Premium")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text("Upgrade to unlock")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        } else if let plant = entry.plants.first {
            VStack(spacing: 8) {
                Text(plant.emoji)
                    .font(.largeTitle)

                Text(plant.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(plant.statusText)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(urgencyColor(plant.urgency))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(urgencyColor(plant.urgency).opacity(0.2))
                    .clipShape(Capsule())
            }
        } else {
            VStack(spacing: 8) {
                Text("🌱")
                    .font(.largeTitle)
                Text("No plants yet")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
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
