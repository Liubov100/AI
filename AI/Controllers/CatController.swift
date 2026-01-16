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
        let speed = running ? runSpeed : walkSpeed
        DispatchQueue.main.async {
            self.facingDirection = .left
            self.position.x -= speed
            self.currentAction = running ? .running : .walking
        }
    }

    func moveRight(running: Bool = false) {
        let speed = running ? runSpeed : walkSpeed
        DispatchQueue.main.async {
            self.facingDirection = .right
            self.position.x += speed
            self.currentAction = running ? .running : .walking
        }
    }

    func moveUp(climbing: Bool = false) {
        let delta = climbing ? -climbSpeed : -walkSpeed
        let action: CatAction = climbing ? .climbing : .walking
        DispatchQueue.main.async {
            self.position.y += delta
            self.currentAction = action
        }
    }

    func moveDown() {
        let delta = walkSpeed
        DispatchQueue.main.async {
            self.position.y += delta
            self.currentAction = .walking
        }
    }

    func jump() {
        guard !isJumping else { return }

        DispatchQueue.main.async {
            self.isJumping = true
            self.currentAction = .jumping
            self.verticalVelocity = self.jumpForce
            self.groundLevel = self.position.y
        }

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
        DispatchQueue.main.async {
            self.isCrawling.toggle()
            self.currentAction = self.isCrawling ? .crawling : .idle
        }
    }

    func startClimbing() {
        DispatchQueue.main.async {
            self.isClimbing = true
            self.currentAction = .climbing
        }
    }

    func stopClimbing() {
        DispatchQueue.main.async {
            self.isClimbing = false
            self.currentAction = .idle
        }
    }

    func knockOver() {
        DispatchQueue.main.async {
            self.currentAction = .knocking
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentAction = .idle
        }
    }

    func steal() {
        DispatchQueue.main.async {
            self.currentAction = .stealing
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.currentAction = .idle
        }
    }

    func hideInBox() {
        DispatchQueue.main.async {
            self.currentAction = .hiding
        }
    }

    func exitBox() {
        DispatchQueue.main.async {
            self.currentAction = .idle
        }
    }

    func stopMovement() {
        DispatchQueue.main.async {
            self.currentAction = .idle
        }
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
