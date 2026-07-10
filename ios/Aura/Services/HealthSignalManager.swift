import Foundation
import OSLog
import SwiftUI

@MainActor
final class HealthSignalManager: ObservableObject {
    static let shared = HealthSignalManager()

    private let logger = Logger(subsystem: "app.aura", category: "health")
    private let vault = PrivacyVault.shared
    private let insight = InsightEngine.shared

    @Published var currentSnapshot: SignalSnapshot?
    @Published var currentState: WeatherState = .flowing

    private var simulatedEnergy: Double = 0.68
    private var simulatedCreative: Double = 0.81
    private var simulatedRest: Double = 0.62

    func bootstrap() async {
        await refreshSignals(forceNewState: true)
    }

    func refreshSignals(forceNewState: Bool = false) async {
        simulatedEnergy = max(0.2, min(0.95, simulatedEnergy + Double.random(in: -0.06...0.07)))
        simulatedCreative = max(0.25, min(0.92, simulatedCreative + Double.random(in: -0.05...0.08)))
        simulatedRest = max(0.3, min(0.9, simulatedRest + Double.random(in: -0.04...0.05)))

        let newState = inferState(energy: simulatedEnergy, creative: simulatedCreative, rest: simulatedRest)

        let snapshot = SignalSnapshot(
            timestamp: Date(),
            energy: simulatedEnergy,
            creative: simulatedCreative,
            restfulness: simulatedRest,
            state: newState
        )

        currentSnapshot = snapshot
        currentState = newState

        vault.append(snapshot)

        if forceNewState || Bool.random() {
            await insight.detectPatternShift()
        }

        logger.info("Aura refreshed — now \(newState.displayName)")
    }

    private func inferState(energy: Double, creative: Double, rest: Double) -> WeatherState {
        if rest > 0.78 { return .hushed }
        if creative > 0.78 && energy > 0.6 { return .flowing }
        if energy < 0.42 && rest > 0.55 { return .settled }
        if creative > 0.55 && energy > 0.5 { return .stirring }
        return .drifting }

    func performBackgroundRefresh() async {
        await refreshSignals()
    }

    func startSimulatedBackgroundCollection() {
        // Real version would register HKObserverQuery + enableBackgroundDelivery
    }
}