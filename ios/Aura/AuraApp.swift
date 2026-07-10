import SwiftUI
import BackgroundTasks
import WidgetKit

@main
struct AuraApp: App {
    @StateObject private var health = HealthSignalManager.shared
    @StateObject private var insight = InsightEngine.shared
    @StateObject private var vault = PrivacyVault.shared

    init() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "app.aura.refresh", using: nil) { task in
            self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(health)
                .environmentObject(insight)
                .environmentObject(vault)
                .task {
                    await health.startSimulatedBackgroundCollection()
                }
        }
    }

    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundRefresh()

        Task {
            await health.performBackgroundRefresh()
            WidgetCenter.shared.reloadAllTimelines()
            task.setTaskCompleted(success: true)
        }
    }

    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "app.aura.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }
}