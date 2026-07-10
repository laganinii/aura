import SwiftUI

enum WeatherState: String, CaseIterable, Codable {
    case flowing
    case settled
    case stirring
    case hushed
    case drifting

    var displayName: String {
        switch self {
        case .flowing: return "flowing"
        case .settled: return "settled"
        case .stirring: return "stirring"
        case .hushed: return "hushed"
        case .drifting: return "drifting"
        }
    }

    var description: String {
        switch self {
        case .flowing: return "A warm, creative current. Good for deep work."
        case .settled: return "Grounded and clear. Gentle productivity."
        case .stirring: return "Energy rising. Ideas are close to the surface."
        case .hushed: return "Quiet, restorative. Protect this space."
        case .drifting: return "Diffuse attention. Good for wandering and noticing."
        }
    }

    var accent: Color {
        switch self {
        case .flowing: return .terracotta
        case .settled: return .sage
        case .stirring: return .amber
        case .hushed: return .clay
        case .drifting: return .taupe
        }
    }
}

struct SignalSnapshot: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let energy: Double
    let creative: Double
    let restfulness: Double
    let state: WeatherState
}

struct MicroExperiment: Identifiable, Codable {
    let id = UUID()
    let title: String
    let body: String
    let cta: String
}