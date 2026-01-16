//
//  FirebaseService.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseVertexAI

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()

    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private var vertex: VertexAI?
    private var model: GenerativeModel?

    @Published var isAuthenticated = false
    @Published var currentUserId: String?

    private init() {
        setupVertex()
        authenticateAnonymously()
    }

    // MARK: - Setup
    private func setupVertex() {
        vertex = VertexAI.vertexAI()
        // Using Gemini 1.5 Pro for better quality quest generation
        model = vertex?.generativeModel(modelName: "gemini-1.5-pro")
    }

    // MARK: - Authentication
    func authenticateAnonymously() {
        auth.signInAnonymously { [weak self] result, error in
            if let error = error {
                print("Authentication error: \(error.localizedDescription)")
                return
            }
            self?.isAuthenticated = true
            self?.currentUserId = result?.user.uid
            print("Authenticated with user ID: \(result?.user.uid ?? "unknown")")
        }
    }

    // MARK: - Save Game State
    func saveGameState(_ gameState: GameState) async throws {
        guard let userId = currentUserId else {
            throw FirebaseError.notAuthenticated
        }

        let data: [String: Any] = [
            "catPosition": ["x": gameState.catPosition.x, "y": gameState.catPosition.y],
            "playerStats": try JSONEncoder().encode(gameState.playerStats).base64EncodedString(),
            "inventory": try JSONEncoder().encode(gameState.inventory).base64EncodedString(),
            "equippedHatId": gameState.equippedHat?.id ?? "",
            "lastUpdated": FieldValue.serverTimestamp()
        ]

        try await db.collection("gameStates").document(userId).setData(data, merge: true)
    }

    // MARK: - Load Game State
    func loadGameState() async throws -> (PlayerStats, Inventory, String)? {
        guard let userId = currentUserId else {
            throw FirebaseError.notAuthenticated
        }

        let document = try await db.collection("gameStates").document(userId).getDocument()

        guard let data = document.data() else {
            return nil
        }

        let playerStatsData = Data(base64Encoded: data["playerStats"] as? String ?? "") ?? Data()
        let inventoryData = Data(base64Encoded: data["inventory"] as? String ?? "") ?? Data()

        let playerStats = try JSONDecoder().decode(PlayerStats.self, from: playerStatsData)
        let inventory = try JSONDecoder().decode(Inventory.self, from: inventoryData)
        let equippedHatId = data["equippedHatId"] as? String ?? ""

        return (playerStats, inventory, equippedHatId)
    }

    // MARK: - Save Quest
    func saveQuest(_ quest: Quest) async throws {
        guard let userId = currentUserId else {
            throw FirebaseError.notAuthenticated
        }

        let questData = try JSONEncoder().encode(quest)
        let questDict = try JSONSerialization.jsonObject(with: questData) as? [String: Any] ?? [:]

        try await db.collection("users").document(userId).collection("quests").document(quest.id).setData(questDict)
    }

    // MARK: - Load Quests
    func loadQuests() async throws -> [Quest] {
        guard let userId = currentUserId else {
            throw FirebaseError.notAuthenticated
        }

        let snapshot = try await db.collection("users").document(userId).collection("quests").getDocuments()

        var quests: [Quest] = []
        for document in snapshot.documents {
            let data = try JSONSerialization.data(withJSONObject: document.data())
            let quest = try JSONDecoder().decode(Quest.self, from: data)
            quests.append(quest)
        }

        return quests
    }
}

// MARK: - AI Quest Generation
extension FirebaseService {
    func generateQuest(context: QuestGenerationContext) async throws -> Quest {
        guard let model = model else {
            throw FirebaseError.aiNotInitialized
        }

        let prompt = buildQuestPrompt(context: context)

        let response = try await model.generateContent(prompt)

        guard let text = response.text else {
            throw FirebaseError.invalidAIResponse
        }

        return try parseQuestFromAI(text: text, context: context)
    }

    private func buildQuestPrompt(context: QuestGenerationContext) -> String {
        """
        You are a quest generator for a cat adventure game called "Little Kitty, Big City".
        Generate a fun, whimsical quest for a curious black cat exploring the city.

        Context:
        - Player has collected \(context.shiniesCollected) shinies
        - Player has eaten \(context.fishEaten) fish
        - Player stamina level: \(context.staminaLevel)
        - Completed quests: \(context.completedQuests)

        Generate a quest with:
        1. A catchy title
        2. A fun description (2-3 sentences)
        3. Objectives (choose 1-3):
           - Collect shinies (amount)
           - Chase birds (amount)
           - Knock over items (amount)
           - Trip people (amount)
           - Visit a specific location
        4. Reward: shinies (5-20) and/or feathers (1-5)

        Format your response as JSON:
        {
          "title": "Quest Title",
          "description": "Quest description",
          "objectives": [
            {"type": "collectShinies", "targetAmount": 5}
          ],
          "reward": {"shinies": 10, "feathers": 2},
          "npcName": "Friendly Crow"
        }

        Make it fun and cat-themed!
        """
    }

    private func parseQuestFromAI(text: String, context: QuestGenerationContext) throws -> Quest {
        let cleanedText = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleanedText.data(using: .utf8) else {
            throw FirebaseError.invalidAIResponse
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        let title = json["title"] as? String ?? "Mysterious Quest"
        let description = json["description"] as? String ?? "Help out around the city!"
        let npcName = json["npcName"] as? String

        let objectivesArray = json["objectives"] as? [[String: Any]] ?? []
        let objectives = objectivesArray.compactMap { obj -> QuestObjective? in
            guard let typeString = obj["type"] as? String,
                  let type = QuestObjectiveType(rawValue: typeString),
                  let target = obj["targetAmount"] as? Int else {
                return nil
            }
            return QuestObjective(type: type, targetAmount: target, currentProgress: 0)
        }

        let rewardDict = json["reward"] as? [String: Any] ?? [:]
        let reward = QuestReward(
            shinies: rewardDict["shinies"] as? Int ?? 10,
            feathers: rewardDict["feathers"] as? Int ?? 0,
            unlockHat: rewardDict["unlockHat"] as? String
        )

        return Quest(
            id: UUID().uuidString,
            title: title,
            description: description,
            objectives: objectives.isEmpty ? [QuestObjective(type: .collectShinies, targetAmount: 5, currentProgress: 0)] : objectives,
            reward: reward,
            status: .available,
            npcName: npcName,
            aiGenerated: true
        )
    }
}

// MARK: - Quest Generation Context
struct QuestGenerationContext {
    let shiniesCollected: Int
    let fishEaten: Int
    let staminaLevel: Int
    let completedQuests: Int
}

// MARK: - Firebase Errors
enum FirebaseError: LocalizedError {
    case notAuthenticated
    case aiNotInitialized
    case invalidAIResponse

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .aiNotInitialized:
            return "AI service is not initialized"
        case .invalidAIResponse:
            return "Invalid response from AI"
        }
    }
}
