//
//  OfflineAIService.swift
//  AI
//
//  Created by Copilot on 1/16/26.
//

import Foundation

class OfflineAIService {
    static let shared = OfflineAIService()
    private init() {}

    // Generates a quest using simple on-device logic and templates.
    func generateQuest(context: QuestGenerationContext) async throws -> Quest {
        // Build dynamic title
        let adjectives = ["Mischievous", "Curious", "Sneaky", "Brave", "Hungry"]
        let places = ["Alley", "Market", "Rooftops", "Park", "Docks"]
        let npcNames = ["Friendly Crow", "Wise Pigeon", "Chatty Squirrel", "Mysterious Rat"]

        let adjective = adjectives.randomElement() ?? "Curious"
        let place = places.randomElement() ?? "Alley"
        let npc = npcNames.randomElement()

        // Decide objective types influenced by context
        var possibleObjectives: [QuestObjectiveType] = [.collectShinies, .collectFeathers, .collectFish, .chaseBirds, .knockOverItems]

        // Prefer fish if player has eaten few fish
        if context.fishEaten < 2 { possibleObjectives.append(.collectFish) }
        if context.staminaLevel < 3 { possibleObjectives.append(.collectFeathers) }

        let objectiveCount = Int.random(in: 1...2)
        var objectives: [QuestObjective] = []

        var chosen = Set<QuestObjectiveType>()
        for _ in 0..<objectiveCount {
            var pick: QuestObjectiveType = possibleObjectives.randomElement() ?? .collectShinies
            // Ensure uniqueness
            var attempts = 0
            while chosen.contains(pick) && attempts < 6 {
                pick = possibleObjectives.randomElement() ?? pick
                attempts += 1
            }
            chosen.insert(pick)

            // Scale target amount with completed quests and player resources
            let base: Int
            switch pick {
            case .collectShinies: base = 3
            case .collectFeathers: base = 2
            case .collectFish: base = 1
            case .chaseBirds: base = 2
            case .knockOverItems: base = 4
            default: base = 2
            }

            let scaled = max(1, base + context.completedQuests / 2 + Int.random(in: 0...2))
            objectives.append(QuestObjective(type: pick, targetAmount: scaled, currentProgress: 0))
        }

        // Reward scales with complexity
        let shiniesReward = 5 + objectives.count * 5 + min(10, context.completedQuests)
        let feathersReward = objectives.contains(where: { $0.type == .collectFeathers }) ? 2 : Int.random(in: 0...3)

        let title = "\(adjective) at the \(place)"
        let description = "\(npc ?? "A local") needs help in the \(place). Complete the tasks to earn rewards and street cred."

        let quest = Quest(
            id: UUID().uuidString,
            title: title,
            description: description,
            objectives: objectives,
            reward: QuestReward(shinies: shiniesReward, feathers: feathersReward, unlockHat: nil),
            status: .available,
            npcName: npc,
            aiGenerated: true
        )

        return quest
    }
}
