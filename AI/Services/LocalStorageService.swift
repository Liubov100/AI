//
//  LocalStorageService.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation

// Lightweight Firebase-backed storage adapter.
// This file replaces previous UserDefaults-backed local storage and now delegates
// persistence to `FirebaseService`. Methods provide both fire-and-forget
// synchronous wrappers and async helpers where appropriate.
class LocalStorageService {
    static let shared = LocalStorageService()

    private init() {}

    // MARK: - Save Methods (fire-and-forget)

    func savePlayerStats(_ stats: PlayerStats) {
        Task { await savePlayerStatsAsync(stats) }
    }

    func saveInventory(_ inventory: Inventory) {
        Task { await saveInventoryAsync(inventory) }
    }

    func saveQuests(_ quests: [Quest]) {
        Task { await saveQuestsAsync(quests) }
    }

    func saveSettings(_ settings: GameSettings) {
        Task { await saveSettingsAsync(settings) }
    }

    func saveTutorialProgress(completed: Bool) {
        Task { await saveTutorialProgressAsync(completed: completed) }
    }

    func saveCatPosition(_ position: CGPoint) {
        Task { await saveCatPositionAsync(position) }
    }

    func saveEquippedHat(_ hatId: String?) {
        Task { await saveEquippedHatAsync(hatId) }
    }

    // MARK: - Async helpers

    func savePlayerStatsAsync(_ stats: PlayerStats) async {
        // Try to merge by loading current inventory from Firebase first
        if let (_, inventory, _) = try? await FirebaseService.shared.loadGameState() {
            try? await FirebaseService.shared.saveGameState(stats: stats, inventory: inventory)
        } else {
            try? await FirebaseService.shared.saveGameState(stats: stats, inventory: Inventory())
        }
    }

    func saveInventoryAsync(_ inventory: Inventory) async {
        if let (playerStats, _, _) = try? await FirebaseService.shared.loadGameState() {
            try? await FirebaseService.shared.saveGameState(stats: playerStats, inventory: inventory)
        } else {
            try? await FirebaseService.shared.saveGameState(stats: PlayerStats(), inventory: inventory)
        }
    }

    func saveQuestsAsync(_ quests: [Quest]) async {
        for quest in quests {
            try? await FirebaseService.shared.saveQuest(quest)
        }
    }

    func saveSettingsAsync(_ settings: GameSettings) async {
        try? await FirebaseService.shared.saveSettings(settings)
    }

    func saveTutorialProgressAsync(completed: Bool) async {
        try? await FirebaseService.shared.saveTutorialProgress(completed: completed)
    }

    func saveCatPositionAsync(_ position: CGPoint) async {
        // Save minimal position data under gameState document if available
        if let (playerStats, inventory, _) = try? await FirebaseService.shared.loadGameState() {
            // Use the GameState save that accepts full GameState if needed
            // Construct a temporary GameState only if required elsewhere; here we update stats/inventory snapshot
            try? await FirebaseService.shared.saveGameState(stats: playerStats, inventory: inventory)
        }
    }

    func saveEquippedHatAsync(_ hatId: String?) async {
        if let (playerStats, inventory, _) = try? await FirebaseService.shared.loadGameState() {
            // save equipped hat id via the full gameState API
            let dummyState = GameState()
            dummyState.playerStats = playerStats
            dummyState.inventory = inventory
            if let hatId = hatId {
                dummyState.equippedHat = Hat(id: hatId, name: "", cost: 0, description: "", isUnlocked: true)
            }
            try? await FirebaseService.shared.saveGameState(dummyState)
        }
    }

    // MARK: - Load Helpers (async)

    func loadGameStateAsync() async -> (PlayerStats?, Inventory?, CGPoint?, String?) {
        if let (stats, inventory, equippedHatId) = try? await FirebaseService.shared.loadGameState() {
            return (stats, inventory, nil, equippedHatId)
        }
        return (nil, nil, nil, nil)
    }

    // Keep simple synchronous stubs for compatibility (return nil/defaults)
    func loadPlayerStats() -> PlayerStats? { return nil }
    func loadInventory() -> Inventory? { return nil }
    func loadQuests() -> [Quest]? { return nil }
    func loadSettings() -> GameSettings? { return nil }
    func loadTutorialProgress() -> Bool { return false }
    func loadCatPosition() -> CGPoint? { return nil }
    func loadEquippedHat() -> String? { return nil }

    // MARK: - Clear / Sync Helpers
    func clearAll() {
        // No-op for Firebase-backed service; removing local-only data.
    }

    func saveGameState(stats: PlayerStats, inventory: Inventory, catPosition: CGPoint, equippedHat: String?) {
        Task {
            try? await FirebaseService.shared.saveGameState(stats: stats, inventory: inventory)
            if equippedHat != nil {
                try? await FirebaseService.shared.saveGameState(stats: stats, inventory: inventory)
            }
        }
    }
}
