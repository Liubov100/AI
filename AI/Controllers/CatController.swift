//
//  CatController.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import SwiftUI
import Combine

class CatController: ObservableObject {
    @Published var position = CGPoint(x: 0, y: 0)
    @Published var currentAction: CatAction = .idle
    @Published var isRunning = false
    @Published var isCrawling = false
    @Published var isClimbing = false
    @Published var facingDirection: Direction = .right

    private var velocity = CGPoint.zero
    private var verticalVelocity: CGFloat = 0
    private var isJumping = false
    private var groundLevel: CGFloat = 0

    private let walkSpeed: CGFloat = 5
    private let runSpeed: CGFloat = 10
    private let jumpForce: CGFloat = -20
    private let gravity: CGFloat = 1.2
    private let climbSpeed: CGFloat = 3

    private var jumpTimer: Timer?

    enum Direction {
        case left, right, up, down
    }

    // MARK: - Movement Controls
    func moveLeft(running: Bool = false) {
        facingDirection = .left
        let speed = running ? runSpeed : walkSpeed
        position.x -= speed
        currentAction = running ? .running : .walking
    }

    func moveRight(running: Bool = false) {
        facingDirection = .right
        let speed = running ? runSpeed : walkSpeed
        position.x += speed
        currentAction = running ? .running : .walking
    }

    func moveUp(climbing: Bool = false) {
        if climbing {
            position.y -= climbSpeed
            currentAction = .climbing
        } else {
            position.y -= walkSpeed
            currentAction = .walking
        }
    }

    func moveDown() {
        position.y += walkSpeed
        currentAction = .walking
    }

    func jump() {
        guard !isJumping else { return }

        isJumping = true
        currentAction = .jumping
        verticalVelocity = jumpForce
        groundLevel = position.y

        // Start jump physics
        jumpTimer?.invalidate()
        jumpTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            // Apply gravity
            self.verticalVelocity += self.gravity

            // Update position
            self.position.y += self.verticalVelocity

            // Check if landed
            if self.position.y >= self.groundLevel {
                self.position.y = self.groundLevel
                self.verticalVelocity = 0
                self.isJumping = false
                self.currentAction = .idle
                timer.invalidate()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentAction = .idle
        }
    }

    func steal() {
        currentAction = .stealing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentAction = .idle
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
    func isNearObject(objectPosition: CGPoint, threshold: CGFloat = 50) -> Bool {
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
}
