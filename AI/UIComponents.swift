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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(gameState.inventory.shinies)")
                    .font(.headline)
            }

            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("\(gameState.inventory.feathers)")
                    .font(.headline)
            }

            HStack {
                Image(systemName: "fish.fill")
                    .foregroundColor(.blue)
                Text("\(gameState.inventory.fish)")
                    .font(.headline)
            }

            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                ForEach(0..<gameState.playerStats.maxStamina, id: \.self) { i in
                    Circle()
                        .fill(i < gameState.playerStats.currentStamina ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 15, height: 15)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
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
            VStack(alignment: .leading) {
                HStack {
                    Text("Quests")
                        .font(.title)
                        .bold()
                    Spacer()
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                }
                .padding()

                ScrollView {
                    ForEach(gameState.quests) { quest in
                        QuestCardView(quest: quest, gameState: gameState)
                            .padding(.horizontal)
                    }
                }

                Button(action: generateNewQuest) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate AI Quest")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .frame(width: 350)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
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
            } catch {
                print("Failed to generate quest: \(error)")
            }
        }
    }
}

// MARK: - Quest Card
struct QuestCardView: View {
    let quest: Quest
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(quest.title)
                    .font(.headline)
                Spacer()
                statusBadge
            }

            Text(quest.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let npc = quest.npcName {
                HStack {
                    Image(systemName: "person.fill")
                    Text(npc)
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }

            ForEach(Array(quest.objectives.enumerated()), id: \.offset) { index, objective in
                HStack {
                    Image(systemName: objective.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(objective.isComplete ? .green : .gray)
                    Text(objectiveText(objective))
                        .font(.caption)
                    Spacer()
                    Text("\(objective.currentProgress)/\(objective.targetAmount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Label("\(quest.reward.shinies)", systemImage: "star.fill")
                    .foregroundColor(.yellow)
                if quest.reward.feathers > 0 {
                    Label("\(quest.reward.feathers)", systemImage: "leaf.fill")
                        .foregroundColor(.green)
                }
                Spacer()

                if quest.status == .available {
                    Button("Accept") {
                        acceptQuest()
                    }
                    .buttonStyle(.borderedProminent)
                } else if quest.status == .readyToComplete {
                    Button("Complete") {
                        completeQuest()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    var statusBadge: some View {
        Text(quest.status.rawValue.capitalized)
            .font(.caption)
            .padding(5)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(5)
    }

    var statusColor: Color {
        switch quest.status {
        case .available: return .blue
        case .active: return .orange
        case .readyToComplete: return .green
        case .completed: return .gray
        }
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
        }
    }

    func completeQuest() {
        gameState.completeQuest(quest)
    }
}

// MARK: - Inventory View
struct InventoryView: View {
    let inventory: Inventory
    @Binding var isShowing: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Inventory")
                        .font(.title)
                        .bold()
                    Spacer()
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                }
                .padding()

                VStack(alignment: .leading, spacing: 20) {
                    inventoryItem(icon: "star.fill", color: .yellow, label: "Shinies", count: inventory.shinies)
                    inventoryItem(icon: "leaf.fill", color: .green, label: "Feathers", count: inventory.feathers)
                    inventoryItem(icon: "fish.fill", color: .blue, label: "Fish", count: inventory.fish)
                    inventoryItem(icon: "crown.fill", color: .purple, label: "Hats Unlocked", count: inventory.hatsUnlocked.count)
                }
                .padding()

                Spacer()
            }
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            Spacer()
        }
        .padding()
    }

    func inventoryItem(icon: String, color: Color, label: String, count: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            Text(label)
                .font(.headline)
            Spacer()
            Text("\(count)")
                .font(.title3)
                .bold()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
        VStack {
            HStack {
                Text("Hat Customization")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            .padding()

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(availableHats) { hat in
                        HatCardView(hat: hat, gameState: gameState)
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 400)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct HatCardView: View {
    let hat: Hat
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack {
            Image(systemName: "crown.fill")
                .font(.largeTitle)
                .foregroundColor(isUnlocked ? .purple : .gray)

            Text(hat.name)
                .font(.headline)

            Text(hat.description)
                .font(.caption)
                .foregroundColor(.secondary)

            if isUnlocked {
                Button(isEquipped ? "Equipped" : "Equip") {
                    gameState.equippedHat = hat
                }
                .buttonStyle(.borderedProminent)
                .disabled(isEquipped)
            } else {
                Button("Unlock: \(hat.cost) ⭐") {
                    unlockHat()
                }
                .buttonStyle(.bordered)
                .disabled(gameState.inventory.shinies < hat.cost)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
        Text(action)
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// MARK: - Controls Help
struct ControlsHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("WASD/Arrows: Move | Space: Jump | C: Crawl | E: Interact")
                .font(.caption)
            Text("Q: Quests | I: Inventory | Shift+Move: Run")
                .font(.caption)
        }
        .padding(10)
        .background(Color.black.opacity(0.5))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
