//
//  CatController.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CatController: ObservableObject {
    @Published var position = CGPoint(x: 0, y: 0)
    @Published var currentAction: CatAction = .idle
    @Published var isRunning = false
    @Published var isCrawling = false
    @Published var isClimbing = false
    @Published var facingDirection: Direction = .right

    private var verticalVelocity: CGFloat = 0
    private var isJumping = false
    private var groundLevel: CGFloat = 0

    private let walkSpeed = GameConfig.Physics.walkSpeed
    private let runSpeed = GameConfig.Physics.runSpeed
    private let jumpForce = GameConfig.Physics.jumpForce
    private let gravity = GameConfig.Physics.gravity
    private let climbSpeed = GameConfig.Physics.climbSpeed

    private var jumpTask: Task<Void, Never>?

    enum Direction {
        case left, right, up, down
    }

    // MARK: - Movement Controls
    func moveLeft(running: Bool = false) {
        guard !isJumping else { return }

        let speed = running ? runSpeed : walkSpeed
        facingDirection = .left
        position.x -= speed
        currentAction = running ? .running : .walking
    }

    func moveRight(running: Bool = false) {
        guard !isJumping else { return }

        let speed = running ? runSpeed : walkSpeed
        facingDirection = .right
        position.x += speed
        currentAction = running ? .running : .walking
    }

    func moveUp(climbing: Bool = false) {
        guard !isJumping else { return }

        let delta = climbing ? -climbSpeed : -walkSpeed
        let action: CatAction = climbing ? .climbing : .walking
        position.y += delta
        currentAction = action
    }

    func moveDown() {
        guard !isJumping else { return }

        let delta = walkSpeed
        position.y += delta
        currentAction = .walking
    }

    func jump() {
        guard !isJumping else { return }

        isJumping = true
        currentAction = .jumping
        verticalVelocity = jumpForce
        groundLevel = position.y

        // Start jump physics using an async Task to avoid publishing during view updates
        jumpTask?.cancel()
        jumpTask = Task { [weak self] in
            guard let self = self else { return }
            let frameDuration = GameConfig.Performance.frameDurationNanoseconds
            while !Task.isCancelled {
                // Compute physics values without touching @Published properties
                let newVerticalVelocity = self.verticalVelocity + self.gravity
                let tentativeY = self.position.y + newVerticalVelocity
                let landed = tentativeY >= self.groundLevel

                // Apply state mutations on the main actor, outside of view update cycles
                await MainActor.run {
                    if landed {
                        self.position.y = self.groundLevel
                        self.verticalVelocity = 0
                        self.isJumping = false
                        self.currentAction = .idle
                        self.jumpTask?.cancel()
                    } else {
                        self.position.y = tentativeY
                        self.verticalVelocity = newVerticalVelocity
                    }
                }

                if landed { break }
                try? await Task.sleep(nanoseconds: frameDuration)
            }
        }
    }

    func toggleCrawl() {
        isCrawling.toggle()
        currentAction = isCrawling ? .crawling : .idle
    }

    func startClimbing() {
        isClimbing = true
        currentAction = .climbing
    }

    func stopClimbing() {
        isClimbing = false
        currentAction = .idle
    }

    func knockOver() {
        currentAction = .knocking
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.currentAction = .idle
        }
    }

    func steal() {
        currentAction = .stealing
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.currentAction = .idle
        }
    }

    func hideInBox() {
        currentAction = .hiding
    }

    func exitBox() {
        currentAction = .idle
    }

    func stopMovement() {
        currentAction = .idle
    }

    // MARK: - Collision Detection
    func isNearObject(objectPosition: CGPoint, threshold: CGFloat = GameConfig.Gameplay.interactionRadius) -> Bool {
        let distance = sqrt(pow(position.x - objectPosition.x, 2) + pow(position.y - objectPosition.y, 2))
        return distance < threshold
    }

    func canClimbHere(obstacles: [CGRect]) -> Bool {
        // Check if cat is near a climbable surface
        for obstacle in obstacles {
            if obstacle.contains(position) || obstacle.insetBy(dx: -20, dy: -20).contains(position) {
                return true
            }
        }
        return false
    }

    deinit {
        jumpTask?.cancel()
    }
}

