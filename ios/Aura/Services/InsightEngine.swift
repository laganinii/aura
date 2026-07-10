import Foundation
import OSLog

@MainActor
final class InsightEngine: ObservableObject {
    static let shared = InsightEngine()

    private let logger = Logger(subsystem: "app.aura", category: "insight")
    private let vault = PrivacyVault.shared

    @Published var currentExperiment: MicroExperiment?
    @Published var baselineShift: String?

    func bootstrap() async {
        await detectPatternShift()
    }

    func detectPatternShift() async {
        let recent = vault.recentSnapshots(hours: 72)
        guard recent.count > 12 else { return }

        let recentAvgRest = recent.map(\.restfulness).reduce(0, +) / Double(recent.count)
        if recentAvgRest < 0.45 {
            baselineShift = "Your evenings have been drifting later than usual."
            currentExperiment = MicroExperiment(
                title: "Your evenings are shifting.",
                body: "Over the past two weeks your wind-down has moved later. The ecosystem is asking for a gentler dusk.",
                cta: "Try a 25-minute wind-down ritual"
            )
        }
    }

    func suggestFromCurrentState(_ state: WeatherState) -> MicroExperiment? {
        switch state {
        case .flowing:
            return MicroExperiment(
                title: "Ride the current",
                body: "Your data shows the strongest creative signatures happen in the first 90 minutes of this state.",
                cta: "Start a focused block"
            )
        case .hushed:
            return MicroExperiment(
                title: "Protect the hush",
                body: "Low stimulation right now produces the deepest rest scores.",
                cta: "Enable Focus mode"
            )
        default:
            return nil
        }
    }
}