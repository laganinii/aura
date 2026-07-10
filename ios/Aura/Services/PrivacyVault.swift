import Foundation
import CryptoKit

@MainActor
final class PrivacyVault: ObservableObject {
    static let shared = PrivacyVault()

    @Published private(set) var snapshots: [SignalSnapshot] = []

    private let storageKey = "aura.vault.snapshots.v1"

    init() {
        load()
    }

    func append(_ snapshot: SignalSnapshot) {
        snapshots.append(snapshot)
        let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        snapshots = snapshots.filter { $0.timestamp > cutoff }
        save()
    }

    func recentSnapshots(hours: Int) -> [SignalSnapshot] {
        let cutoff = Calendar.current.date(byAdding: .hour, value: -hours, to: Date())!
        return snapshots.filter { $0.timestamp > cutoff }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(snapshots) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SignalSnapshot].self, from: data) else {
            snapshots = []
            return
        }
        snapshots = decoded
    }

    func deleteAll() {
        snapshots = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}