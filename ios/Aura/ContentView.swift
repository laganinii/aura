import SwiftUI

struct ContentView: View {
    @EnvironmentObject var health: HealthSignalManager
    @EnvironmentObject var insight: InsightEngine

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header

                    EcosystemView(state: $health.currentState)
                        .frame(height: 320)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(LinearGradient(colors: [.sand, .oat.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: Color.espresso.opacity(0.12), radius: 18, y: 8)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        metricCard(title: "Energy", value: health.currentSnapshot?.energy ?? 0.7, trend: "+9%")
                        metricCard(title: "Creative", value: health.currentSnapshot?.creative ?? 0.82, trend: "Peak")
                    }

                    if let exp = insight.currentExperiment ?? insight.suggestFromCurrentState(health.currentState) {
                        insightCard(exp)
                    }

                    Text("Aura updates in the background using HealthKit observers and BGAppRefresh. Your phone knows how you are even when the app is closed.")
                        .font(.caption)
                        .foregroundStyle(.taupe)
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(
                LinearGradient(colors: [.oat, .sand], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Aura")
                        .font(.custom("Fraunces-Italic", size: 22))
                        .foregroundStyle(.terracotta)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await health.refreshSignals(forceNewState: true) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .tint(.terracotta)
        .task {
            await health.bootstrap()
            await insight.bootstrap()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tuesday · Week 46")
                .font(.caption.smallCaps())
                .foregroundStyle(.taupe)
                .tracking(0.6)

            (Text("You are ") + Text(health.currentState.displayName).italic().foregroundStyle(health.currentState.accent) + Text("."))
                .font(.custom("Fraunces", size: 34))
                .foregroundStyle(.espresso)

            Text(health.currentState.description)
                .font(.subheadline)
                .foregroundStyle(.taupe)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metricCard(title: String, value: Double, trend: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.medium))
                .foregroundStyle(.taupe)
                .tracking(0.8)

            Text(value > 0.7 ? "Rising" : value > 0.55 ? "Steady" : "Low")
                .font(.custom("Fraunces", size: 20))
                .foregroundStyle(.espresso)

            Text(trend)
                .font(.caption)
                .foregroundStyle(.sage)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.oat)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.latte, lineWidth: 1)
                )
        )
    }

    private func insightCard(_ exp: MicroExperiment) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("GENTLE NUDGE")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.taupe)
                .tracking(1)

            Text(exp.title)
                .font(.custom("Fraunces", size: 19))

            Text(exp.body)
                .font(.subheadline)
                .foregroundStyle(.taupe)

            Button(exp.cta) {
                insight.currentExperiment = nil
            }
            .buttonStyle(.borderedProminent)
            .tint(.espresso)
            .foregroundStyle(.oat)
            .controlSize(.small)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.sand)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.latte, lineWidth: 1)
                )
        )
    }
}