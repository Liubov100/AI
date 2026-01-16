//
//  Models.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State
class GameState: ObservableObject {
    @Published var catPosition = CGPoint(x: 0, y: 0)
    @Published var playerStats = PlayerStats()
    @Published var inventory = Inventory()
    @Published var quests: [Quest] = []
    @Published var activeQuest: Quest?
    @Published var discoveredLocations: [FastTravelPoint] = []
    @Published var equippedHat: Hat?

    func collectItem(_ item: Collectable) {
        inventory.add(item)
        checkQuestProgress(for: item)
    }

    func checkQuestProgress(for item: Collectable) {
        for i in 0..<quests.count {
            if quests[i].status == .active {
                quests[i].updateProgress(collectedItem: item)
            }
        }
    }

    func completeQuest(_ quest: Quest) {
        if let index = quests.firstIndex(where: { $0.id == quest.id }) {
            quests[index].status = .completed
            inventory.shinies += quest.reward.shinies
            inventory.feathers += quest.reward.feathers
        }
    }
}

// MARK: - Player Stats
struct PlayerStats: Codable {
    var maxStamina: Int = 1
    var currentStamina: Int = 1
    var fishEaten: Int = 0
    var birdsChased: Int = 0
    var itemsKnockedOver: Int = 0
    var peopleTripped: Int = 0

    mutating func eatFish() {
        fishEaten += 1
        maxStamina = min(4, fishEaten + 1)
        currentStamina = maxStamina
    }
}

// MARK: - Inventory
struct Inventory: Codable {
    var shinies: Int = 0
    var feathers: Int = 0
    var fish: Int = 0
    var hatsUnlocked: [String] = []
    var collectedItems: [String] = []

    mutating func add(_ item: Collectable) {
        switch item.type {
        case .shiny:
            shinies += 1
        case .feather:
            feathers += 1
        case .fish:
            fish += 1
        case .hat:
            if let hatId = item.hatId {
                hatsUnlocked.append(hatId)
            }
        }
        collectedItems.append(item.id)
    }

    func hasItem(id: String) -> Bool {
        collectedItems.contains(id)
    }
}

// MARK: - Collectable
struct Collectable: Identifiable, Codable {
    let id: String
    let type: CollectableType
    let position: CGPoint
    var isCollected: Bool = false
    let hatId: String?

    init(id: String, type: CollectableType, position: CGPoint, hatId: String? = nil) {
        self.id = id
        self.type = type
        self.position = position
        self.hatId = hatId
    }
}

enum CollectableType: String, Codable {
    case shiny
    case feather
    case fish
    case hat
}

// MARK: - Quest System
struct Quest: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var objectives: [QuestObjective]
    var reward: QuestReward
    var status: QuestStatus
    var npcName: String?
    var aiGenerated: Bool

    mutating func updateProgress(collectedItem: Collectable) {
        for i in 0..<objectives.count {
            if objectives[i].type.matches(collectable: collectedItem.type) {
                objectives[i].currentProgress += 1
            }
        }

        if isComplete {
            status = .readyToComplete
        }
    }

    var isComplete: Bool {
        objectives.allSatisfy { $0.isComplete }
    }
}

struct QuestObjective: Codable {
    let type: QuestObjectiveType
    let targetAmount: Int
    var currentProgress: Int

    var isComplete: Bool {
        currentProgress >= targetAmount
    }
}

enum QuestObjectiveType: String, Codable {
    case collectShinies
    case collectFeathers
    case collectFish
    case knockOverItems
    case tripPeople
    case chaseBirds
    case visitLocation
    case talkToNPC

    func matches(collectable: CollectableType) -> Bool {
        switch (self, collectable) {
        case (.collectShinies, .shiny): return true
        case (.collectFeathers, .feather): return true
        case (.collectFish, .fish): return true
        default: return false
        }
    }
}

struct QuestReward: Codable {
    var shinies: Int
    var feathers: Int
    var unlockHat: String?
}

enum QuestStatus: String, Codable {
    case available
    case active
    case readyToComplete
    case completed
}

// MARK: - Hat System
struct Hat: Identifiable, Codable {
    let id: String
    let name: String
    let cost: Int
    let description: String
    var isUnlocked: Bool
}

// MARK: - Fast Travel
struct FastTravelPoint: Identifiable, Codable {
    let id: String
    let name: String
    let position: CGPoint
    let featherCost: Int
    var isDiscovered: Bool
}

// MARK: - NPC
struct NPC: Identifiable {
    let id: String
    let name: String
    let animalType: AnimalType
    let position: CGPoint
    var dialogue: [String]
    var questsAvailable: [Quest]
}

enum AnimalType: String, Codable {
    case crow
    case dog
    case duck
    case pigeon
    case squirrel
    case rat
}

// MARK: - Interactive Objects
struct InteractiveObject: Identifiable {
    let id: String
    let type: ObjectType
    var position: CGPoint
    var isInteracted: Bool = false
}

enum ObjectType: String {
    case trashCan
    case box
    case vase
    case foodStall
    case person
    case bird
}

// MARK: - Cat Actions
enum CatAction {
    case idle
    case walking
    case running
    case jumping
    case crawling
    case climbing
    case knocking
    case stealing
    case hiding
}
