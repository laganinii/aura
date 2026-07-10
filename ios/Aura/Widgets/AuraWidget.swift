import WidgetKit
import SwiftUI

struct AuraWidgetEntry: TimelineEntry {
    let date: Date
    let state: WeatherState
    let energy: Double
}

struct AuraWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AuraWidgetEntry {
        AuraWidgetEntry(date: Date(), state: .flowing, energy: 0.78)
    }

    func getSnapshot(in context: Context, completion: @escaping (AuraWidgetEntry) -> Void) {
        let entry = AuraWidgetEntry(date: Date(), state: .flowing, energy: 0.81)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AuraWidgetEntry>) -> Void) {
        let current = HealthSignalManager.shared.currentState
        let energy = HealthSignalManager.shared.currentSnapshot?.energy ?? 0.7

        let entry = AuraWidgetEntry(date: Date(), state: current, energy: energy)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(20 * 60)))
        completion(timeline)
    }
}

struct AuraWidget: Widget {
    let kind = "AuraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AuraWidgetProvider()) { entry in
            VStack(alignment: .leading, spacing: 4) {
                Text("AURA")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.terracotta.opacity(0.7))

                Text(entry.state.displayName.capitalized)
                    .font(.custom("Fraunces", size: 22))
                    .foregroundStyle(entry.state.accent)

                Text("Energy \(Int(entry.energy * 100))%")
                    .font(.caption)
                    .foregroundStyle(.taupe)
            }
            .padding(14)
            .containerBackground(for: .widget) {
                LinearGradient(colors: [.oat, .sand], startPoint: .top, endPoint: .bottom)
            }
        }
        .configurationDisplayName("Aura")
        .description("Your current inner weather")
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}