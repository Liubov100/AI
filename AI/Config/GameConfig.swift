//
//  GameConfig.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import Foundation
import CoreGraphics

enum GameConfig {
    // MARK: - Physics
    enum Physics {
        static let walkSpeed: CGFloat = 5
        static let runSpeed: CGFloat = 10
        static let climbSpeed: CGFloat = 3
        static let jumpForce: CGFloat = -20
        static let gravity: CGFloat = 1.2
    }

    // MARK: - Gameplay
    enum Gameplay {
        static let collectionRadius: CGFloat = 40
        static let interactionRadius: CGFloat = 50
        static let saveDebounceSeconds: Double = 0.5
    }

    // MARK: - XP Rewards
    enum XPRewards {
        static let collectShiny = 10
        static let collectFish = 15
        static let collectFeather = 20
        static let collectHat = 50
        static let questBaseReward = 50
        static let questObjectiveBonus = 25
    }

    // MARK: - Currency Rewards
    enum CurrencyRewards {
        static let questBaseShillings = 100
        static let questObjectiveBonus = 50
        static let levelUpShillings = 50
        static let starCoinsPerFiveLevels = 10
    }

    // MARK: - Progression
    enum Progression {
        static let baseXPForNextLevel = 100
        static let xpIncreasePerLevel = 50
        static let maxStamina = 10
        static let staminaPerLevel = 1
    }

    // MARK: - Performance
    enum Performance {
        static let targetFPS: UInt64 = 60
        static let frameDurationNanoseconds: UInt64 = 16_666_667
    }
}
