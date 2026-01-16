//
//  LocalStorageService.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation

// MARK: - Local Storage Service
class LocalStorageService {
    static let shared = LocalStorageService()

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Keys
    private enum Keys {
        static let playerStats = "local_playerStats"
        static let inventory = "local_inventory"
        static let quests = "local_quests"
        static let settings = "local_settings"
        static let tutorialCompleted = "local_tutorialCompleted"
        static let catPosition = "local_catPosition"
        static let equippedHat = "local_equippedHat"
    }

    private init() {}

    // MARK: - Save Methods

    func savePlayerStats(_ stats: PlayerStats) {
        if let data = try? encoder.encode(stats) {
            userDefaults.set(data, forKey: Keys.playerStats)
            print("💾 Saved player stats locally")
        }
    }

    func saveInventory(_ inventory: Inventory) {
        if let data = try? encoder.encode(inventory) {
            userDefaults.set(data, forKey: Keys.inventory)
            print("💾 Saved inventory locally")
        }
    }

    func saveQuests(_ quests: [Quest]) {
        if let data = try? encoder.encode(quests) {
            userDefaults.set(data, forKey: Keys.quests)
            print("💾 Saved \(quests.count) quests locally")
        }
    }

    func saveSettings(_ settings: GameSettings) {
        if let data = try? encoder.encode(settings) {
            userDefaults.set(data, forKey: Keys.settings)
            print("💾 Saved settings locally")
        }
    }

    func saveTutorialProgress(completed: Bool) {
        userDefaults.set(completed, forKey: Keys.tutorialCompleted)
        print("💾 Saved tutorial progress locally: \(completed)")
    }

    func saveCatPosition(_ position: CGPoint) {
        let dict: [String: Double] = ["x": Double(position.x), "y": Double(position.y)]
        userDefaults.set(dict, forKey: Keys.catPosition)
    }

    func saveEquippedHat(_ hatId: String?) {
        userDefaults.set(hatId, forKey: Keys.equippedHat)
    }

    // MARK: - Load Methods

    func loadPlayerStats() -> PlayerStats? {
        guard let data = userDefaults.data(forKey: Keys.playerStats),
              let stats = try? decoder.decode(PlayerStats.self, from: data) else {
            return nil
        }
        print("📂 Loaded player stats from local storage")
        return stats
    }

    func loadInventory() -> Inventory? {
        guard let data = userDefaults.data(forKey: Keys.inventory),
              let inventory = try? decoder.decode(Inventory.self, from: data) else {
            return nil
        }
        print("📂 Loaded inventory from local storage")
        return inventory
    }

    func loadQuests() -> [Quest]? {
        guard let data = userDefaults.data(forKey: Keys.quests),
              let quests = try? decoder.decode([Quest].self, from: data) else {
            return nil
        }
        print("📂 Loaded \(quests.count) quests from local storage")
        return quests
    }

    func loadSettings() -> GameSettings? {
        guard let data = userDefaults.data(forKey: Keys.settings),
              let settings = try? decoder.decode(GameSettings.self, from: data) else {
            return nil
        }
        print("📂 Loaded settings from local storage")
        return settings
    }

    func loadTutorialProgress() -> Bool {
        let completed = userDefaults.bool(forKey: Keys.tutorialCompleted)
        print("📂 Loaded tutorial progress from local storage: \(completed)")
        return completed
    }

    func loadCatPosition() -> CGPoint? {
        guard let dict = userDefaults.dictionary(forKey: Keys.catPosition),
              let x = dict["x"] as? Double,
              let y = dict["y"] as? Double else {
            return nil
        }
        return CGPoint(x: x, y: y)
    }

    func loadEquippedHat() -> String? {
        return userDefaults.string(forKey: Keys.equippedHat)
    }

    // MARK: - Clear Methods

    func clearAll() {
        userDefaults.removeObject(forKey: Keys.playerStats)
        userDefaults.removeObject(forKey: Keys.inventory)
        userDefaults.removeObject(forKey: Keys.quests)
        userDefaults.removeObject(forKey: Keys.settings)
        userDefaults.removeObject(forKey: Keys.tutorialCompleted)
        userDefaults.removeObject(forKey: Keys.catPosition)
        userDefaults.removeObject(forKey: Keys.equippedHat)
        print("🗑️ Cleared all local storage")
    }

    // MARK: - Sync Methods

    func saveGameState(stats: PlayerStats, inventory: Inventory, catPosition: CGPoint, equippedHat: String?) {
        savePlayerStats(stats)
        saveInventory(inventory)
        saveCatPosition(catPosition)
        saveEquippedHat(equippedHat)
        print("💾 Saved complete game state locally")
    }

    func loadGameState() -> (PlayerStats?, Inventory?, CGPoint?, String?) {
        let stats = loadPlayerStats()
        let inventory = loadInventory()
        let position = loadCatPosition()
        let hat = loadEquippedHat()

        if stats != nil || inventory != nil {
            print("📂 Loaded game state from local storage")
        }

        return (stats, inventory, position, hat)
    }
}
