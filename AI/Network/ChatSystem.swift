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
}

// MARK: - Chat Manager
@MainActor
class ChatManager: ObservableObject {
    static let shared = ChatManager()

    @Published var messages: [ChatMessage] = []
    @Published var unreadCount: Int = 0

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
            Task { @MainActor in
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

    func sendMessage(senderId: String, senderName: String, message: String, isAI: Bool = false) {
        let chatMessage = ChatMessage(
            id: UUID().uuidString,
            senderId: senderId,
            senderName: senderName,
            message: message,
            timestamp: Date(),
            isAI: isAI
        )

        messages.append(chatMessage)

        // Keep only last 50 messages
        if messages.count > 50 {
            messages.removeFirst()
        }

        if isAI {
            unreadCount += 1
        }
    }

    func markAsRead() {
        unreadCount = 0
    }

    func clearMessages() {
        messages.removeAll()
        unreadCount = 0
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
