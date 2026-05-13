import Foundation

@MainActor
final class PresetsStore {
    static let shared = PresetsStore()

    private let ubiquitousStore = NSUbiquitousKeyValueStore.default
    private let storeKey = StorageKeys.Presets.store

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    func load() -> [Preset] {
        ubiquitousStore.synchronize()

        guard let data = ubiquitousStore.data(forKey: storeKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([Preset].self, from: data)
        } catch {
            AppLogger.presets.error("Failed to decode presets: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    func save(_ presets: [Preset]) {
        do {
            let data = try encoder.encode(presets)
            ubiquitousStore.set(data, forKey: storeKey)
            ubiquitousStore.synchronize()
        } catch {
            AppLogger.presets.error("Failed to save presets: \(error.localizedDescription, privacy: .public)")
        }
    }

    func clearAll() {
        ubiquitousStore.removeObject(forKey: storeKey)
        ubiquitousStore.synchronize()
    }
}
