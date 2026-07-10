import ActivityKit
import WidgetKit
import SwiftUI

struct AuraAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var state: String
        var energy: Double
        var message: String
    }

    let startTime: Date
}

struct AuraLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AuraAttributes.self) { context in
            HStack {
                VStack(alignment: .leading) {
                    Text("Aura")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(context.state.state.capitalized)
                        .font(.custom("Fraunces", size: 20))
                        .foregroundStyle(Color.terracotta)
                }
                Spacer()
                Text("\(Int(context.state.energy * 100))%")
                    .font(.title3.monospacedDigit())
            }
            .padding()
            .activityBackgroundTint(Color.oat)
            .activitySystemActionForegroundColor(.espresso)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.state.capitalized)
                        .font(.custom("Fraunces", size: 16))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.energy * 100))")
                        .font(.title3)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.message)
                        .font(.caption)
                        .foregroundStyle(.taupe)
                }
            } compactLeading: {
                Text("🌿")
            } compactTrailing: {
                Text("\(Int(context.state.energy * 100))")
                    .font(.caption.monospacedDigit())
            } minimal: {
                Text("A")
                    .font(.caption.bold())
            }
        }
    }
}

@MainActor
func startAuraLiveActivity(state: WeatherState, energy: Double) {
    let attributes = AuraAttributes(startTime: Date())
    let initialState = AuraAttributes.ContentState(
        state: state.displayName,
        energy: energy,
        message: state.description
    )

    do {
        let activity = try Activity.request(attributes: attributes, contentState: initialState)
        print("Started Aura Live Activity: \(activity.id)")
    } catch {
        print("Failed to start Live Activity: \(error)")
    }
}