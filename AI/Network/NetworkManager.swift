//
//  NetworkManager.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import Combine

// MARK: - Network Player
struct NetworkPlayer: Identifiable, Codable {
    let id: String
    var name: String
    var position: CGPoint
    var facingDirection: String // "left", "right", "up", "down"
    var currentAction: String // CatAction as string
    var level: Int
    var isAI: Bool
    var lastUpdate: Date
}

// MARK: - Network Manager
@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()

    @Published var connectedPlayers: [NetworkPlayer] = []
    @Published var isConnected = false
    @Published var localPlayerId: String

    private var updateTimer: Timer?
    private let maxAIPlayers = 5

    private init() {
        self.localPlayerId = UUID().uuidString
        startAIPlayers()
    }

    // MARK: - AI Player Management
    func startAIPlayers() {
        // Spawn AI players in different locations
        let aiNames = ["Shadow", "Whiskers", "Mittens", "Luna", "Felix"]
        let startPositions = [
            CGPoint(x: 100, y: 100),
            CGPoint(x: -100, y: -100),
            CGPoint(x: 150, y: -50),
            CGPoint(x: -120, y: 80),
            CGPoint(x: 50, y: -150)
        ]

        for i in 0..<maxAIPlayers {
            let aiPlayer = NetworkPlayer(
                id: "AI_\(i)",
                name: aiNames[i],
                position: startPositions[i],
                facingDirection: "right",
                currentAction: "idle",
                level: Int.random(in: 1...10),
                isAI: true,
                lastUpdate: Date()
            )
            connectedPlayers.append(aiPlayer)
        }

        // Start AI update loop
        startAIUpdateLoop()
        isConnected = true
    }

    private func startAIUpdateLoop() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateAIPlayers()
            }
        }
    }

    private func updateAIPlayers() {
        for i in 0..<connectedPlayers.count where connectedPlayers[i].isAI {
            connectedPlayers[i] = AIPlayerBehavior.update(connectedPlayers[i])
        }
    }

    // MARK: - Player Updates
    func updateLocalPlayer(position: CGPoint, facingDirection: CatController.Direction, action: CatAction) {
        // In a real implementation, this would send updates to a server
        // For now, we just track the local player
    }

    func disconnect() {
        updateTimer?.invalidate()
        updateTimer = nil
        connectedPlayers.removeAll()
        isConnected = false
    }

    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - AI Player Behavior
struct AIPlayerBehavior {
    static func update(_ player: NetworkPlayer) -> NetworkPlayer {
        var updated = player
        updated.lastUpdate = Date()

        // Random movement patterns
        let behavior = Int.random(in: 0...100)

        switch behavior {
        case 0...60: // Wander
            let deltaX = CGFloat.random(in: -3...3)
            let deltaY = CGFloat.random(in: -3...3)
            updated.position.x += deltaX
            updated.position.y += deltaY
            updated.currentAction = "walking"

            // Update facing direction based on movement
            if abs(deltaX) > abs(deltaY) {
                updated.facingDirection = deltaX > 0 ? "right" : "left"
            } else {
                updated.facingDirection = deltaY > 0 ? "down" : "up"
            }

        case 61...70: // Jump
            updated.currentAction = "jumping"

        case 71...80: // Idle
            updated.currentAction = "idle"

        case 81...85: // Run
            let deltaX = CGFloat.random(in: -6...6)
            let deltaY = CGFloat.random(in: -6...6)
            updated.position.x += deltaX
            updated.position.y += deltaY
            updated.currentAction = "running"

        case 86...90: // Crawl
            updated.currentAction = "crawling"

        default: // Stay put
            break
        }

        // Keep AI players within bounds
        updated.position.x = max(-300, min(300, updated.position.x))
        updated.position.y = max(-300, min(300, updated.position.y))

        return updated
    }
}
