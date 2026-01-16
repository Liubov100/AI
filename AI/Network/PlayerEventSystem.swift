//
//  PlayerEventSystem.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Player Event Types
enum PlayerEventType {
    case playerJoined
    case playerLeft
    case playerLevelUp
    case playerFoundShiny
    case playerCompletedQuest
    case playerUnlockedHat
    case playerAchievement
}

// MARK: - Player Event
struct PlayerEvent: Identifiable {
    let id = UUID()
    let type: PlayerEventType
    let playerName: String
    let message: String
    let icon: String
    let color: Color
    let timestamp: Date
}

// MARK: - Player Event Manager
@MainActor
class PlayerEventManager: ObservableObject {
    static let shared = PlayerEventManager()

    @Published var recentEvents: [PlayerEvent] = []
    @Published var currentNotification: PlayerEvent?
    @Published var showNotification = false

    private var eventTimer: Timer?
    private var notificationQueue: [PlayerEvent] = []
    private var isShowingNotification = false

    private init() {
        startEventGeneration()
    }

    // MARK: - Start Event Generation
    private func startEventGeneration() {
        // Generate random player events
        eventTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.generateRandomEvent()
            }
        }

        // Initial join events for all AI players
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.generateInitialJoinEvents()
        }
    }

    private func generateInitialJoinEvents() {
        let aiNames = ["Shadow", "Whiskers", "Mittens", "Luna", "Felix"]

        for (index, name) in aiNames.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
                self.addEvent(
                    type: .playerJoined,
                    playerName: name,
                    message: "\(name) joined the game!",
                    icon: "person.crop.circle.badge.plus",
                    color: .green
                )
            }
        }
    }

    private func generateRandomEvent() {
        let aiNames = ["Shadow", "Whiskers", "Mittens", "Luna", "Felix"]
        let randomPlayer = aiNames.randomElement()!

        let eventTypes: [(PlayerEventType, Double)] = [
            (.playerFoundShiny, 0.3),
            (.playerLevelUp, 0.15),
            (.playerCompletedQuest, 0.2),
            (.playerUnlockedHat, 0.15),
            (.playerAchievement, 0.1),
            (.playerJoined, 0.05),
            (.playerLeft, 0.05)
        ]

        let random = Double.random(in: 0...1)
        var cumulative = 0.0

        for (eventType, probability) in eventTypes {
            cumulative += probability
            if random <= cumulative {
                generateEvent(type: eventType, playerName: randomPlayer)
                break
            }
        }
    }

    private func generateEvent(type: PlayerEventType, playerName: String) {
        switch type {
        case .playerJoined:
            addEvent(
                type: .playerJoined,
                playerName: playerName,
                message: "\(playerName) joined the game!",
                icon: "person.crop.circle.badge.plus",
                color: .green
            )

        case .playerLeft:
            addEvent(
                type: .playerLeft,
                playerName: playerName,
                message: "\(playerName) left the game",
                icon: "person.crop.circle.badge.minus",
                color: .gray
            )

            // Respawn after 15 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                self.addEvent(
                    type: .playerJoined,
                    playerName: playerName,
                    message: "\(playerName) joined the game!",
                    icon: "person.crop.circle.badge.plus",
                    color: .green
                )
            }

        case .playerLevelUp:
            let level = Int.random(in: 2...15)
            addEvent(
                type: .playerLevelUp,
                playerName: playerName,
                message: "\(playerName) reached Level \(level)!",
                icon: "star.fill",
                color: .yellow
            )

        case .playerFoundShiny:
            let count = Int.random(in: 1...5)
            let plural = count > 1 ? "shinies" : "shiny"
            addEvent(
                type: .playerFoundShiny,
                playerName: playerName,
                message: "\(playerName) found \(count) \(plural)!",
                icon: "sparkles",
                color: .yellow
            )

        case .playerCompletedQuest:
            let quests = ["City Explorer", "Bird Watcher", "Mischief Maker", "Feather Collector"]
            let quest = quests.randomElement()!
            addEvent(
                type: .playerCompletedQuest,
                playerName: playerName,
                message: "\(playerName) completed '\(quest)'!",
                icon: "checkmark.circle.fill",
                color: .green
            )

        case .playerUnlockedHat:
            let hats = ["Top Hat", "Crown", "Beret", "Wizard Hat"]
            let hat = hats.randomElement()!
            addEvent(
                type: .playerUnlockedHat,
                playerName: playerName,
                message: "\(playerName) unlocked the \(hat)!",
                icon: "crown.fill",
                color: .purple
            )

        case .playerAchievement:
            let achievements = [
                "Master Explorer",
                "Shiny Collector",
                "Bird Chaser",
                "Troublemaker",
                "Hat Enthusiast"
            ]
            let achievement = achievements.randomElement()!
            addEvent(
                type: .playerAchievement,
                playerName: playerName,
                message: "\(playerName) earned '\(achievement)'!",
                icon: "trophy.fill",
                color: .orange
            )
        }
    }

    // MARK: - Add Event
    func addEvent(type: PlayerEventType, playerName: String, message: String, icon: String, color: Color) {
        let event = PlayerEvent(
            type: type,
            playerName: playerName,
            message: message,
            icon: icon,
            color: color,
            timestamp: Date()
        )

        recentEvents.append(event)

        // Keep only last 20 events
        if recentEvents.count > 20 {
            recentEvents.removeFirst()
        }

        // Queue notification
        notificationQueue.append(event)
        showNextNotification()
    }

    private func showNextNotification() {
        guard !isShowingNotification, !notificationQueue.isEmpty else { return }

        isShowingNotification = true
        let event = notificationQueue.removeFirst()

        currentNotification = event
        showNotification = true

        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showNotification = false
            self.isShowingNotification = false

            // Show next notification after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showNextNotification()
            }
        }
    }

    // MARK: - Manual Events (for local player achievements)
    func playerFoundItem(itemType: String, count: Int = 1) {
        let plural = count > 1 ? "s" : ""
        addEvent(
            type: .playerFoundShiny,
            playerName: "You",
            message: "You found \(count) \(itemType)\(plural)!",
            icon: "sparkles",
            color: .cyan
        )
    }

    func playerLeveledUp(level: Int) {
        addEvent(
            type: .playerLevelUp,
            playerName: "You",
            message: "You reached Level \(level)!",
            icon: "star.fill",
            color: .cyan
        )
    }

    deinit {
        eventTimer?.invalidate()
    }
}
