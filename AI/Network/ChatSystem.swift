//
//  ChatSystem.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable {
    let id: String
    let senderId: String
    let senderName: String
    let message: String
    let timestamp: Date
    let isAI: Bool
    let recipientId: String? // nil for global chat, playerId for private messages

    init(id: String = UUID().uuidString, senderId: String, senderName: String, message: String, timestamp: Date = Date(), isAI: Bool, recipientId: String? = nil) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.message = message
        self.timestamp = timestamp
        self.isAI = isAI
        self.recipientId = recipientId
    }
}

// MARK: - AI Personality
enum AIPersonality {
    case friendly
    case sarcastic
    case mysterious
    case cheerful
    case wise

    var greetings: [String] {
        switch self {
        case .friendly:
            return ["Hey there!", "Hi friend!", "Hello! Nice to see you!", "Meow! How are you?"]
        case .sarcastic:
            return ["Oh great, another cat...", "Fancy meeting you here.", "What a surprise."]
        case .mysterious:
            return ["...", "I've been expecting you.", "The shadows whisper your name."]
        case .cheerful:
            return ["YAY! A new friend!!", "This is SO exciting!", "OMG HI!!"]
        case .wise:
            return ["Greetings, young one.", "The path reveals itself.", "Welcome, traveler."]
        }
    }

    var randomMessages: [String] {
        switch self {
        case .friendly:
            return [
                "Beautiful day for exploring!",
                "Found any good shinies lately?",
                "Want to team up?",
                "This city is amazing!",
                "Have you tried the fish here? Delicious!"
            ]
        case .sarcastic:
            return [
                "Wow, another shiny. How original.",
                "Yeah, I'm totally interested in that quest.",
                "Sure, climbing is fun... if you're into that.",
                "Oh look, a bird. Never seen one of those before.",
                "This place gets more exciting by the second."
            ]
        case .mysterious:
            return [
                "The moon reveals secrets...",
                "Do you hear them too?",
                "Not all that glitters is gold.",
                "There's more to this city than meets the eye.",
                "Follow the shadows..."
            ]
        case .cheerful:
            return [
                "This is the BEST day ever!",
                "I just found THREE shinies!!",
                "Wanna race?!",
                "You're awesome!",
                "Let's be friends forever!"
            ]
        case .wise:
            return [
                "Patience brings all things.",
                "The journey is the destination.",
                "Observe before you act.",
                "Each shiny holds a lesson.",
                "Balance is the key to mastery."
            ]
        }
    }

    func responseToMessage(_ message: String) -> String {
        let lowercased = message.lowercased()

        // Check for greetings
        if lowercased.contains("hi") || lowercased.contains("hello") || lowercased.contains("hey") {
            return greetings.randomElement()!
        }

        // Check for questions about shinies
        if lowercased.contains("shiny") || lowercased.contains("shinies") {
            switch self {
            case .friendly:
                return ["I found some near the buildings!", "Check by the trees!", "The lamp posts usually have some nearby!"].randomElement()!
            case .sarcastic:
                return ["Look harder, they're everywhere.", "Maybe try using your eyes?", "They're literally shining, how hard can it be?"].randomElement()!
            case .mysterious:
                return ["Follow the light...", "The shiniest treasures hide in shadows.", "Look where others don't."].randomElement()!
            case .cheerful:
                return ["I LOVE shinies!! They're SO pretty!", "I can help you find some!!", "Let's go shiny hunting together!"].randomElement()!
            case .wise:
                return ["Shinies appear to those who wander with purpose.", "Patience reveals hidden treasures.", "The city provides for the observant."].randomElement()!
            }
        }

        // Check for questions about quests
        if lowercased.contains("quest") {
            switch self {
            case .friendly:
                return ["I'm working on collecting feathers! What about you?", "The quests here are pretty fun!", "Want to do a quest together?"].randomElement()!
            case .sarcastic:
                return ["Oh, you mean those super exciting tasks?", "Yeah, quests. Real groundbreaking stuff.", "Thrilling. Absolutely thrilling."].randomElement()!
            case .mysterious:
                return ["Some quests are not what they seem...", "The true quest is within.", "Choose your path wisely."].randomElement()!
            case .cheerful:
                return ["Quests are SO much fun!!", "I just completed one!! It was AMAZING!", "Let's do ALL the quests!!"].randomElement()!
            case .wise:
                return ["Each quest teaches a valuable lesson.", "The journey matters more than the reward.", "Embrace the challenge before you."].randomElement()!
            }
        }

        // Check for general questions (how, what, where, why)
        if lowercased.contains("how") || lowercased.contains("what") || lowercased.contains("where") || lowercased.contains("why") {
            switch self {
            case .friendly:
                return ["Good question! Let me think...", "Hmm, I'm not entirely sure, but...", "That's interesting! I wonder too."].randomElement()!
            case .sarcastic:
                return ["Wouldn't we all like to know?", "That's the million-dollar question, isn't it?", "Your guess is as good as mine."].randomElement()!
            case .mysterious:
                return ["The answer lies within you...", "Some questions have no answers.", "Seek and you shall find."].randomElement()!
            case .cheerful:
                return ["That's a great question!!", "I love your curiosity!", "Let's figure it out together!!"].randomElement()!
            case .wise:
                return ["The answer reveals itself in time.", "Ask not what, but why.", "Understanding comes from within."].randomElement()!
            }
        }

        // Default response
        return randomMessages.randomElement()!
    }
}

// MARK: - Chat Manager
@MainActor
class ChatManager: ObservableObject {
    static let shared = ChatManager()

    @Published var messages: [ChatMessage] = [] // Global chat messages
    @Published var unreadCount: Int = 0
    @Published var privateConversations: [String: [ChatMessage]] = [:] // friendId -> messages
    @Published var unreadPrivateMessages: [String: Int] = [:] // friendId -> unread count

    private var aiPersonalities: [String: AIPersonality] = [:]
    private var lastAIMessage: [String: Date] = [:]
    private var chatTimer: Timer?

    private init() {
        setupAIPersonalities()
        startAIChatLoop()
    }

    private func setupAIPersonalities() {
        aiPersonalities["AI_0"] = .friendly
        aiPersonalities["AI_1"] = .sarcastic
        aiPersonalities["AI_2"] = .mysterious
        aiPersonalities["AI_3"] = .cheerful
        aiPersonalities["AI_4"] = .wise
    }

    private func startAIChatLoop() {
        chatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.triggerRandomAIMessage()
            }
        }
    }

    private func triggerRandomAIMessage() {
        // Random chance for AI to send a message
        guard Bool.random() else { return }

        // Pick a random AI player
        let aiPlayers = Array(aiPersonalities.keys)
        guard !aiPlayers.isEmpty else { return }

        let randomAI = aiPlayers.randomElement()!
        guard let personality = aiPersonalities[randomAI] else { return }

        // Check if enough time has passed since last message from this AI
        if let lastTime = lastAIMessage[randomAI],
           Date().timeIntervalSince(lastTime) < 10 {
            return
        }

        // Generate message based on context
        let message = generateAIMessage(personality: personality, senderId: randomAI)
        sendMessage(senderId: randomAI, senderName: getPlayerName(randomAI), message: message, isAI: true)

        lastAIMessage[randomAI] = Date()
    }

    private func generateAIMessage(personality: AIPersonality, senderId: String) -> String {
        // 20% chance to greet, 80% chance for random message
        if Bool.random(probability: 0.2) {
            return personality.greetings.randomElement()!
        } else {
            return personality.randomMessages.randomElement()!
        }
    }

    private func getPlayerName(_ playerId: String) -> String {
        let names = ["Shadow", "Whiskers", "Mittens", "Luna", "Felix"]
        let index = Int(playerId.components(separatedBy: "_").last ?? "0") ?? 0
        return names[index]
    }

    func sendMessage(senderId: String, senderName: String, message: String, isAI: Bool = false, recipientId: String? = nil) {
        let chatMessage = ChatMessage(
            id: UUID().uuidString,
            senderId: senderId,
            senderName: senderName,
            message: message,
            timestamp: Date(),
            isAI: isAI,
            recipientId: recipientId
        )

        if let recipientId = recipientId {
            // Private message
            let conversationId = getConversationId(senderId: senderId, recipientId: recipientId)

            if privateConversations[conversationId] == nil {
                privateConversations[conversationId] = []
            }
            privateConversations[conversationId]?.append(chatMessage)

            // Keep only last 100 private messages per conversation
            if privateConversations[conversationId]!.count > 100 {
                privateConversations[conversationId]?.removeFirst()
            }

            // If it's from AI, mark as unread
            if isAI {
                unreadPrivateMessages[conversationId, default: 0] += 1
            }

            // AI auto-responds to private messages
            if !isAI, let personality = aiPersonalities[recipientId] {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...3)) {
                    let response = personality.responseToMessage(message)
                    self.sendMessage(
                        senderId: recipientId,
                        senderName: self.getPlayerName(recipientId),
                        message: response,
                        isAI: true,
                        recipientId: senderId
                    )
                }
            }
        } else {
            // Global message
            messages.append(chatMessage)

            // Keep only last 50 messages
            if messages.count > 50 {
                messages.removeFirst()
            }

            if isAI {
                unreadCount += 1
            }
        }
    }

    func getConversationId(senderId: String, recipientId: String) -> String {
        // Always use consistent ordering for conversation ID
        let sorted = [senderId, recipientId].sorted()
        return "\(sorted[0])_\(sorted[1])"
    }

    func getPrivateMessages(withFriend friendId: String, localPlayerId: String) -> [ChatMessage] {
        let conversationId = getConversationId(senderId: localPlayerId, recipientId: friendId)
        return privateConversations[conversationId] ?? []
    }

    func markAsRead() {
        unreadCount = 0
    }

    func markPrivateChatAsRead(friendId: String, localPlayerId: String) {
        let conversationId = getConversationId(senderId: localPlayerId, recipientId: friendId)
        unreadPrivateMessages[conversationId] = 0
    }

    func getTotalUnreadPrivateMessages() -> Int {
        return unreadPrivateMessages.values.reduce(0, +)
    }

    func getUnreadCount(forFriend friendId: String, localPlayerId: String) -> Int {
        let conversationId = getConversationId(senderId: localPlayerId, recipientId: friendId)
        return unreadPrivateMessages[conversationId] ?? 0
    }

    func clearMessages() {
        messages.removeAll()
        unreadCount = 0
    }

    func clearPrivateConversation(friendId: String, localPlayerId: String) {
        let conversationId = getConversationId(senderId: localPlayerId, recipientId: friendId)
        privateConversations[conversationId] = []
        unreadPrivateMessages[conversationId] = 0
    }

    deinit {
        chatTimer?.invalidate()
    }
}

// MARK: - Helper Extension
extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
