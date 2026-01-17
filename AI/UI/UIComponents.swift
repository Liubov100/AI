//
//  UIComponents.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

// MARK: - Stats Panel
struct StatsPanel: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StatRow(icon: "star.fill", iconColor: .yellow, value: "\(gameState.inventory.shinies)")
            StatRow(icon: "leaf.fill", iconColor: .green, value: "\(gameState.inventory.feathers)")
            StatRow(icon: "fish.fill", iconColor: .cyan, value: "\(gameState.inventory.fish)")

            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                    .frame(width: 20)

                HStack(spacing: 4) {
                    ForEach(0..<gameState.playerStats.maxStamina, id: \.self) { i in
                        Circle()
                            .fill(i < gameState.playerStats.currentStamina ?
                                  LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                  LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: i < gameState.playerStats.currentStamina ? .orange.opacity(0.4) : .clear, radius: 2)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
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
        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Stat Row Helper
struct StatRow: View {
    let icon: String
    let iconColor: Color
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 14))
                .frame(width: 20)

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 1)
        }
    }
}

// MARK: - Collectable View
struct CollectableView: View {
    let collectable: Collectable

    var body: some View {
        Group {
            switch collectable.type {
            case .shiny:
                ShinyView()
            case .feather:
                FeatherView()
            case .fish:
                FishView()
            case .hat:
                Image(systemName: "crown.fill")
                    .foregroundColor(.purple)
                    .font(.title)
            }
        }
    }
}

// MARK: - NPC View
struct NPCView: View {
    let npc: NPC

    var body: some View {
        VStack {
            animalIcon
            Text(npc.name)
                .font(.caption)
                .padding(5)
                .background(Color.white.opacity(0.8))
                .cornerRadius(5)
        }
    }

    @ViewBuilder
    var animalIcon: some View {
        switch npc.animalType {
        case .crow:
            Image(systemName: "bird.fill")
                .font(.largeTitle)
                .foregroundColor(.black)
        case .dog:
            Image(systemName: "pawprint.fill")
                .font(.largeTitle)
                .foregroundColor(.brown)
        case .duck:
            Image(systemName: "bird.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
        case .pigeon:
            Image(systemName: "bird.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
        case .squirrel:
            Image(systemName: "hare.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
        case .rat:
            Image(systemName: "hare.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Quest Panel
struct QuestPanelView: View {
    @ObservedObject var gameState: GameState
    @Binding var isShowing: Bool

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                // Header with gradient background
                HStack {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    Text("Quests")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Quest list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(gameState.quests) { quest in
                            QuestCardView(quest: quest, gameState: gameState)
                        }
                    }
                    .padding()
                }
                .background(Color(.windowBackgroundColor))

                // Generate button with improved styling
                Button(action: generateNewQuest) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Generate AI Quest")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .padding()
                .background(Color(.windowBackgroundColor))
            }
            .frame(width: 380)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
        }
        .padding()
    }

    func generateNewQuest() {
        Task {
            let context = QuestGenerationContext(
                shiniesCollected: gameState.inventory.shinies,
                fishEaten: gameState.playerStats.fishEaten,
                staminaLevel: gameState.playerStats.maxStamina,
                completedQuests: gameState.quests.filter { $0.status == .completed }.count
            )

            do {
                let quest = try await FirebaseService.shared.generateQuest(context: context)
                await MainActor.run {
                    gameState.quests.append(quest)
                }

                // Save AI-generated quest to Firebase
                if quest.aiGenerated {
                    try? await FirebaseService.shared.saveQuest(quest)
                }
                } catch {
                }
        }
    }
}

// MARK: - Quest Card
struct QuestCardView: View {
    let quest: Quest
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and status
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)

                    if let npc = quest.npcName {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10))
                            Text(npc)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.blue)
                    }
                }
                Spacer()
                statusBadge
            }

            Text(quest.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Objectives
            VStack(spacing: 8) {
                ForEach(Array(quest.objectives.enumerated()), id: \.offset) { index, objective in
                    HStack(spacing: 8) {
                        Image(systemName: objective.isComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(objective.isComplete ? .green : .gray.opacity(0.6))
                            .font(.system(size: 14))

                        Text(objectiveText(objective))
                            .font(.system(size: 13))
                            .foregroundColor(objective.isComplete ? .secondary : .primary)

                        Spacer()

                        Text("\(objective.currentProgress)/\(objective.targetAmount)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 4)

            Divider()

            // Rewards and action button
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    RewardBadge(icon: "star.fill", color: .yellow, amount: quest.reward.shinies)
                    if quest.reward.feathers > 0 {
                        RewardBadge(icon: "leaf.fill", color: .green, amount: quest.reward.feathers)
                    }
                }

                Spacer()

                if quest.status == .available {
                    Button(action: acceptQuest) {
                        Text("Accept")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                } else if quest.status == .readyToComplete {
                    Button(action: completeQuest) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                            Text("Complete")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(statusColor.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    var statusBadge: some View {
        Text(quest.status.rawValue.capitalized)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(statusColor)
            )
            .foregroundColor(.white)
            .shadow(color: statusColor.opacity(0.4), radius: 3)
    }

    var statusColor: Color {
        switch quest.status {
        case .available: return .blue
        case .active: return .orange
        case .readyToComplete: return .green
        case .completed: return .gray
        }
    }
}

// MARK: - Reward Badge Helper
struct RewardBadge: View {
    let icon: String
    let color: Color
    let amount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text("\(amount)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }

    func objectiveText(_ objective: QuestObjective) -> String {
        switch objective.type {
        case .collectShinies: return "Collect Shinies"
        case .collectFeathers: return "Collect Feathers"
        case .collectFish: return "Find Fish"
        case .knockOverItems: return "Knock Over Items"
        case .tripPeople: return "Trip People"
        case .chaseBirds: return "Chase Birds"
        case .visitLocation: return "Visit Location"
        case .talkToNPC: return "Talk to NPC"
        }
    }

    func acceptQuest() {
        if let index = gameState.quests.firstIndex(where: { $0.id == quest.id }) {
            gameState.quests[index].status = .active
            gameState.activeQuest = gameState.quests[index]
            gameState.scheduleSave()
        }
    }

    func completeQuest() {
        gameState.completeQuest(quest)
        // completeQuest already schedules save
    }
}

// MARK: - Inventory View
struct InventoryView: View {
    let inventory: Inventory
    @Binding var isShowing: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header with gradient
                HStack {
                    Image(systemName: "backpack.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    Text("Inventory")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Inventory items
                ScrollView {
                    VStack(spacing: 14) {
                        inventoryItem(icon: "star.fill", color: .yellow, label: "Shinies", count: inventory.shinies)
                        inventoryItem(icon: "leaf.fill", color: .green, label: "Feathers", count: inventory.feathers)
                        inventoryItem(icon: "fish.fill", color: .cyan, label: "Fish", count: inventory.fish)
                        inventoryItem(icon: "crown.fill", color: .purple, label: "Hats Unlocked", count: inventory.hatsUnlocked.count)
                    }
                    .padding()
                }
                .background(Color(.windowBackgroundColor))

                Spacer()
            }
            .frame(width: 340)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
            Spacer()
        }
        .padding()
    }

    func inventoryItem(icon: String, color: Color, label: String, count: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: color.opacity(0.4), radius: 4)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Text(label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()

            Text("\(count)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Hat Customization
struct HatCustomizationView: View {
    @ObservedObject var gameState: GameState
    @Binding var isShowing: Bool

    let availableHats = [
        Hat(id: "tophat", name: "Top Hat", cost: 20, description: "Fancy!", isUnlocked: false),
        Hat(id: "crown", name: "Crown", cost: 50, description: "Royal!", isUnlocked: false),
        Hat(id: "beret", name: "Beret", cost: 15, description: "Artistic!", isUnlocked: false),
        Hat(id: "wizard", name: "Wizard Hat", cost: 30, description: "Magical!", isUnlocked: false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text("Hat Customization")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Hat grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                    ForEach(availableHats) { hat in
                        HatCardView(hat: hat, gameState: gameState)
                    }
                }
                .padding()
            }
            .background(Color(.windowBackgroundColor))
        }
        .frame(width: 540, height: 450)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
    }
}

struct HatCardView: View {
    let hat: Hat
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ?
                                [Color.purple.opacity(0.3), Color.pink.opacity(0.2)] :
                                [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isUnlocked ? .purple : .gray.opacity(0.5))
            }
            .shadow(color: isUnlocked ? .purple.opacity(0.3) : .clear, radius: 5)

            VStack(spacing: 4) {
                Text(hat.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)

                Text(hat.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            if isUnlocked {
                Button(action: {
                    gameState.equippedHat = hat
                    gameState.scheduleSave()
                }) {
                    Text(isEquipped ? "Equipped" : "Equip")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(isEquipped ? .gray : .purple)
                .disabled(isEquipped)
            } else {
                Button(action: unlockHat) {
                    HStack(spacing: 4) {
                        Text("Unlock")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("\(hat.cost)")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(.yellow)
                .disabled(gameState.inventory.shinies < hat.cost)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isUnlocked ? Color.purple.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }

    var isUnlocked: Bool {
        gameState.inventory.hatsUnlocked.contains(hat.id)
    }

    var isEquipped: Bool {
        gameState.equippedHat?.id == hat.id
    }

    func unlockHat() {
        if gameState.inventory.shinies >= hat.cost {
            gameState.inventory.shinies -= hat.cost
            gameState.inventory.hatsUnlocked.append(hat.id)
            gameState.scheduleSave()
        }
    }
}


// MARK: - City Environment
struct CityEnvironmentView: View {
    @Binding var collectables: [Collectable]
    @Binding var objects: [InteractiveObject]

    var body: some View {
        ZStack {
            // Ground
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .offset(y: 300)

            // Buildings (simple rectangles)
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 400)
                .offset(x: -250, y: 0)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 300)
                .offset(x: 280, y: 50)

            // Render interactive objects
            ForEach(objects) { object in
                InteractiveObjectView(object: object)
                    .offset(x: object.position.x, y: object.position.y)
            }
        }
    }
}

// MARK: - Interactive Object View
struct InteractiveObjectView: View {
    let object: InteractiveObject

    var body: some View {
        Group {
            switch object.type {
            case .box:
                BoxView()
            case .trashCan:
                TrashCanView()
            case .vase:
                VaseView()
            case .bird:
                BirdView()
            case .foodStall:
                // Placeholder for food stall
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.brown)
                    .frame(width: 60, height: 40)
            case .person:
                // Simple person placeholder
                VStack(spacing: 2) {
                    Circle()
                        .fill(Color.pink.opacity(0.8))
                        .frame(width: 15, height: 15)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 20, height: 30)
                }
            }
        }
    }
}

// MARK: - Action Hint
struct ActionHintView: View {
    let action: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 14))
                .foregroundColor(.yellow)

            Text(action)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.85), Color.black.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Controls Help
struct ControlsHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                ControlKey("WASD")
                Text("/ Arrows: Move |")
                ControlKey("Space")
                Text(": Jump |")
                ControlKey("C")
                Text(": Crawl |")
                ControlKey("E")
                Text(": Interact")
            }
            .font(.system(size: 11, weight: .medium))

            HStack(spacing: 4) {
                ControlKey("Q")
                Text(": Quests |")
                ControlKey("I")
                Text(": Inventory | Chat: Talk with AI |")
                ControlKey("Shift")
                Text("+ Move: Run")
            }
            .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.75), Color.black.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Control Key Helper
struct ControlKey: View {
    let key: String

    init(_ key: String) {
        self.key = key
    }

    var body: some View {
        Text(key)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color.gray.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}
