//
//  LocalStorageService.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation

class LocalStorageService {
    static let shared = LocalStorageService()

    private let defaults = UserDefaults.standard
    private let firebaseService = FirebaseService.shared

    private init() {}

    // MARK: - Save Methods (with offline fallback)

    func savePlayerStats(_ stats: PlayerStats) {
        Task {
            do {
                try await firebaseService.savePlayerStats(stats)
            } catch {
                savePlayerStatsLocally(stats)
            }
        }
    }

    func saveInventory(_ inventory: Inventory) {
        Task {
            do {
                try await firebaseService.saveInventory(inventory)
            } catch {
                saveInventoryLocally(inventory)
            }
        }
    }

    func saveQuests(_ quests: [Quest]) {
        Task {
            do {
                for quest in quests {
                    try await firebaseService.saveQuest(quest)
                }
            } catch {
                saveQuestsLocally(quests)
            }
        }
    }

    func saveSettings(_ settings: GameSettings) {
        Task {
            do {
                try await firebaseService.saveSettings(settings)
            } catch {
                saveSettingsLocally(settings)
            }
        }
    }

    func saveTutorialProgress(completed: Bool) {
        Task {
            do {
                try await firebaseService.saveTutorialProgress(completed: completed)
            } catch {
                defaults.set(completed, forKey: "tutorialCompleted")
            }
        }
    }

    func saveCatPosition(_ position: CGPoint) {
        Task {
            do {
                try await firebaseService.saveCatPosition(position)
            } catch {
                saveCatPositionLocally(position)
            }
        }
    }

    func saveEquippedHat(_ hatId: String?) {
        Task {
            do {
                try await firebaseService.saveEquippedHat(hatId)
            } catch {
                defaults.set(hatId, forKey: "equippedHatId")
            }
        }
    }

    func saveGameState(stats: PlayerStats, inventory: Inventory, catPosition: CGPoint, equippedHat: String?) {
        Task {
            do {
                try await firebaseService.saveGameState(stats: stats, inventory: inventory)
                try await firebaseService.saveCatPosition(catPosition)
                if let hatId = equippedHat {
                    try await firebaseService.saveEquippedHat(hatId)
                }
            } catch {
                savePlayerStatsLocally(stats)
                saveInventoryLocally(inventory)
                saveCatPositionLocally(catPosition)
                defaults.set(equippedHat, forKey: "equippedHatId")
            }
        }
    }

    // MARK: - Local Storage Fallback (UserDefaults)

    private func savePlayerStatsLocally(_ stats: PlayerStats) {
        if let encoded = try? JSONEncoder().encode(stats) {
            defaults.set(encoded, forKey: "playerStats")
        }
    }

    private func saveInventoryLocally(_ inventory: Inventory) {
        if let encoded = try? JSONEncoder().encode(inventory) {
            defaults.set(encoded, forKey: "inventory")
        }
    }

    private func saveQuestsLocally(_ quests: [Quest]) {
        if let encoded = try? JSONEncoder().encode(quests) {
            defaults.set(encoded, forKey: "quests")
        }
    }

    private func saveSettingsLocally(_ settings: GameSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: "settings")
        }
    }

    private func saveCatPositionLocally(_ position: CGPoint) {
        let positionDict = ["x": position.x, "y": position.y]
        defaults.set(positionDict, forKey: "catPosition")
    }

    // MARK: - Load Helpers (with Firebase priority, fallback to local)

    func loadGameStateAsync() async -> (PlayerStats?, Inventory?, CGPoint?, String?) {
        if let (stats, inventory, equippedHatId) = try? await firebaseService.loadGameState() {
            return (stats, inventory, nil, equippedHatId)
        }

        // Fallback to local storage
        let stats = loadPlayerStats()
        let inventory = loadInventory()
        let position = loadCatPosition()
        let hatId = loadEquippedHat()

        return (stats, inventory, position, hatId)
    }

    // MARK: - Synchronous Load Methods (local only)

    func loadPlayerStats() -> PlayerStats? {
        guard let data = defaults.data(forKey: "playerStats") else { return nil }
        return try? JSONDecoder().decode(PlayerStats.self, from: data)
    }

    func loadInventory() -> Inventory? {
        guard let data = defaults.data(forKey: "inventory") else { return nil }
        return try? JSONDecoder().decode(Inventory.self, from: data)
    }

    func loadQuests() -> [Quest]? {
        guard let data = defaults.data(forKey: "quests") else { return nil }
        return try? JSONDecoder().decode([Quest].self, from: data)
    }

    func loadSettings() -> GameSettings? {
        guard let data = defaults.data(forKey: "settings") else { return nil }
        return try? JSONDecoder().decode(GameSettings.self, from: data)
    }

    func loadTutorialProgress() -> Bool {
        return defaults.bool(forKey: "tutorialCompleted")
    }

    func loadCatPosition() -> CGPoint? {
        guard let dict = defaults.dictionary(forKey: "catPosition"),
              let x = dict["x"] as? CGFloat,
              let y = dict["y"] as? CGFloat else { return nil }
        return CGPoint(x: x, y: y)
    }

    func loadEquippedHat() -> String? {
        return defaults.string(forKey: "equippedHatId")
    }

    // MARK: - Clear All Data

    func clearAll() {
        let keys = ["playerStats", "inventory", "quests", "settings", "tutorialCompleted", "catPosition", "equippedHatId"]
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
}
