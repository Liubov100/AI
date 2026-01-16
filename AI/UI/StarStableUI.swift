//
//  StarStableUI.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

// MARK: - Level Bar (Star Stable Inspired)
struct LevelBarView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Character portrait background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.3), radius: 3)

                    // Cat icon
                    Text("🐱")
                        .font(.title)
                }

                VStack(alignment: .leading, spacing: 2) {
                    // Cat name
                    Text(gameState.playerStats.catName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)

                    // Level and XP
                    HStack(spacing: 4) {
                        Text("Level \(gameState.playerStats.level)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.5), radius: 1)

                        Text("•")
                            .foregroundColor(.white.opacity(0.5))

                        Text("\(gameState.playerStats.currentXP)/\(gameState.playerStats.xpToNextLevel) XP")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.5), radius: 1)
                    }

                    // XP Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.black.opacity(0.6), Color.black.opacity(0.4)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )

                            // Foreground (filled part)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(gameState.playerStats.levelProgress), height: 16)
                                .shadow(color: .yellow.opacity(0.6), radius: 3)
                                .animation(.easeInOut(duration: 0.5), value: gameState.playerStats.levelProgress)

                            // Shine effect
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(gameState.playerStats.levelProgress), height: 8)
                        }
                    }
                    .frame(height: 16)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Currency Display (Star Stable Inspired)
struct CurrencyDisplayView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 8) {
            // Star Coins (Premium currency)
            CurrencyRow(
                icon: "star.fill",
                iconColor: .yellow,
                amount: gameState.playerStats.starCoins,
                backgroundColor: Color.purple.opacity(0.8)
            )

            // Jorvik Shillings (Regular currency)
            CurrencyRow(
                icon: "dollarsign.circle.fill",
                iconColor: .green,
                amount: gameState.playerStats.jorvikShillings,
                backgroundColor: Color.green.opacity(0.6)
            )

            // Shinies (Collectible)
            CurrencyRow(
                icon: "sparkles",
                iconColor: .orange,
                amount: gameState.inventory.shinies,
                backgroundColor: Color.orange.opacity(0.6)
            )

            // Feathers (Travel currency)
            CurrencyRow(
                icon: "leaf.fill",
                iconColor: .cyan,
                amount: gameState.inventory.feathers,
                backgroundColor: Color.cyan.opacity(0.6)
            )
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
    }
}

struct CurrencyRow: View {
    let icon: String
    let iconColor: Color
    let amount: Int
    let backgroundColor: Color

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 28, height: 28)
                    .shadow(color: iconColor.opacity(0.5), radius: 2)

                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }

            Text("\(amount)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 1)
                .frame(minWidth: 50, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.3))
        )
    }
}

// MARK: - Notification Toast (Star Stable Inspired)
struct NotificationToast: View {
    let title: String
    let message: String
    let icon: String
    let iconColor: Color
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.8), iconColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: iconColor.opacity(0.5), radius: 3)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: 350)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.85), Color.black.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Level Up Celebration
struct LevelUpView: View {
    let newLevel: Int
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }

            VStack(spacing: 20) {
                // Sparkles animation
                ZStack {
                    ForEach(0..<8) { i in
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .offset(x: cos(Double(i) * .pi / 4) * 60, y: sin(Double(i) * .pi / 4) * 60)
                            .opacity(0.8)
                    }

                    Text("\(newLevel)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 20)
                }

                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .yellow, radius: 10)

                    Text("You reached level \(newLevel)!")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }

                // Rewards
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rewards:")
                        .font(.headline)
                        .foregroundColor(.yellow)

                    HStack(spacing: 20) {
                        RewardItem(icon: "bolt.fill", text: "+1 Stamina", color: .blue)
                        RewardItem(icon: "dollarsign.circle.fill", text: "+\(newLevel * 50)", color: .green)
                        if newLevel % 5 == 0 {
                            RewardItem(icon: "star.fill", text: "+10", color: .yellow)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.5))
                )

                Button(action: {
                    withAnimation {
                        isShowing = false
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: .blue.opacity(0.5), radius: 5)
                }
                .buttonStyle(.plain)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.7), radius: 20)
        }
        .zIndex(1500)
    }
}

struct RewardItem: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Settings Data Model
struct GameSettings: Codable, Equatable {
    var masterVolume: Double = 1.0
    var musicVolume: Double = 0.7
    var sfxVolume: Double = 0.8
    var particleEffects: Bool = true
    var catName: String = "Kitty"
}

#Preview("Level Bar") {
    LevelBarView(gameState: GameState())
        .padding()
        .frame(width: 300)
        .background(Color.gray.opacity(0.2))
}

#Preview("Currency Display") {
    CurrencyDisplayView(gameState: GameState())
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Level Up") {
    LevelUpView(newLevel: 5, isShowing: .constant(true))
}
