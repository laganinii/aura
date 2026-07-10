import SwiftUI

struct EcosystemView: View {
    @Binding var state: WeatherState
    @State private var blobs: [Blob] = Blob.seed(for: .flowing)

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                let bg = Gradient(colors: [Color.sand, Color.oat.opacity(0.85)])
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(bg, startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height))
                )

                context.addFilter(.blur(radius: 26))
                for blob in blobs {
                    let pos = blob.position(at: t, in: size)
                    let rect = CGRect(x: pos.x - blob.radius, y: pos.y - blob.radius,
                                      width: blob.radius * 2, height: blob.radius * 2)

                    let grad = Gradient(colors: [blob.color, blob.color.opacity(0)])
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .radialGradient(grad, center: pos, startRadius: 6, endRadius: blob.radius)
                    )
                }
                context.addFilter(.blur(radius: 0))
            }
            .onChange(of: state) { _, newState in
                withAnimation(.easeInOut(duration: 1.4)) {
                    blobs = Blob.seed(for: newState)
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Inner Ecosystem")
                    .font(.system(size: 10, weight: .medium, design: .default))
                    .foregroundStyle(Color.espresso.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text("now")
                    .font(.custom("Fraunces-Italic", size: 13))
                    .foregroundStyle(Color.espresso)
            }
            .padding(16)
        }
    }
}

struct Blob: Identifiable {
    let id = UUID()
    var anchor: CGPoint
    var radius: CGFloat
    var color: Color
    var speed: Double
    var phase: Double

    func position(at t: TimeInterval, in size: CGSize) -> CGPoint {
        let dx = sin(t * speed + phase) * 38
        let dy = cos(t * speed * 0.65 + phase * 1.1) * 26
        return CGPoint(
            x: anchor.x * size.width + dx,
            y: anchor.y * size.height + dy
        )
    }

    static func seed(for state: WeatherState) -> [Blob] {
        switch state {
        case .flowing:
            return [
                .init(anchor: .init(x: 0.28, y: 0.32), radius: 118, color: .terracotta.opacity(0.58), speed: 0.72, phase: 0),
                .init(anchor: .init(x: 0.68, y: 0.26), radius: 96, color: .amber.opacity(0.52), speed: 0.91, phase: 1.7),
                .init(anchor: .init(x: 0.46, y: 0.61), radius: 132, color: .sage.opacity(0.48), speed: 0.64, phase: 2.9),
                .init(anchor: .init(x: 0.19, y: 0.71), radius: 74, color: .clay.opacity(0.42), speed: 0.83, phase: 4.1),
            ]
        case .settled:
            return [
                .init(anchor: .init(x: 0.42, y: 0.48), radius: 96, color: .sage.opacity(0.55), speed: 0.32, phase: 0),
                .init(anchor: .init(x: 0.61, y: 0.39), radius: 72, color: .amber.opacity(0.38), speed: 0.41, phase: 2.1),
            ]
        case .stirring:
            return [
                .init(anchor: .init(x: 0.31, y: 0.29), radius: 82, color: .amber.opacity(0.6), speed: 1.1, phase: 0.4),
                .init(anchor: .init(x: 0.59, y: 0.52), radius: 105, color: .terracotta.opacity(0.45), speed: 0.95, phase: 1.8),
            ]
        case .hushed:
            return [
                .init(anchor: .init(x: 0.48, y: 0.55), radius: 110, color: .clay.opacity(0.5), speed: 0.28, phase: 0),
            ]
        case .drifting:
            return [
                .init(anchor: .init(x: 0.25, y: 0.35), radius: 68, color: .taupe.opacity(0.35), speed: 0.55, phase: 1),
                .init(anchor: .init(x: 0.72, y: 0.48), radius: 82, color: .sage.opacity(0.32), speed: 0.48, phase: 3.2),
            ]
        }
    }
}