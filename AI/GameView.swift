//
//  GameView.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameState = GameState()
    @StateObject private var catController = CatController()
    @StateObject private var firebaseService = FirebaseService.shared

    @State private var showQuestPanel = false
    @State private var showInventory = false
    @State private var showHatCustomization = false
    @State private var collectables: [Collectable] = []
    @State private var npcs: [NPC] = []
    @State private var interactiveObjects: [InteractiveObject] = []
    @State private var isShiftPressed = false

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.8, green: 0.9, blue: 1.0)
                .ignoresSafeArea()

            // City Environment
            CityEnvironmentView(collectables: $collectables, objects: $interactiveObjects)

            // NPCs
            ForEach(npcs) { npc in
                NPCView(npc: npc)
                    .offset(x: npc.position.x, y: npc.position.y)
            }

            // Collectables
            ForEach(collectables.filter { !$0.isCollected }) { collectable in
                CollectableView(collectable: collectable)
                    .offset(x: collectable.position.x, y: collectable.position.y)
            }

            // Player Cat
            BlackCat()
                .scaleEffect(catController.facingDirection == .left ? CGSize(width: -0.5, height: 0.5) : CGSize(width: 0.5, height: 0.5))
                .offset(x: catController.position.x, y: catController.position.y)
                .overlay(
                    catController.currentAction == .hiding ? Color.clear : nil
                )

            // UI Overlays
            VStack {
                HStack {
                    StatsPanel(gameState: gameState)
                    Spacer()
                    HStack(spacing: 15) {
                        Button(action: { showInventory.toggle() }) {
                            Image(systemName: "backpack")
                                .font(.title2)
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                        Button(action: { showQuestPanel.toggle() }) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.title2)
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                        Button(action: { showHatCustomization.toggle() }) {
                            Image(systemName: "crown")
                                .font(.title2)
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()

                Spacer()

                // Action Hints
                if let nearbyObject = findNearbyInteractable() {
                    ActionHintView(action: nearbyObject)
                        .padding(.bottom, 20)
                }

                // Controls Help
                ControlsHelpView()
                    .padding(.bottom)
            }

            // Quest Panel
            if showQuestPanel {
                QuestPanelView(gameState: gameState, isShowing: $showQuestPanel)
                    .transition(.move(edge: .trailing))
            }

            // Inventory
            if showInventory {
                InventoryView(inventory: gameState.inventory, isShowing: $showInventory)
                    .transition(.move(edge: .leading))
            }

            // Hat Customization
            if showHatCustomization {
                HatCustomizationView(gameState: gameState, isShowing: $showHatCustomization)
                    .transition(.scale)
            }
        }
        .focusable()
        .onKeyPress(characters: .alphanumerics) { keyPress in
            handleCharacterPress(keyPress.characters)
            return .handled
        }
        .onKeyPress(keys: [.upArrow, .downArrow, .leftArrow, .rightArrow, .space]) { keyPress in
            handleSpecialKeyPress(keyPress.key)
            return .handled
        }
        .onAppear {
            setupGame()
        }
    }

    // MARK: - Setup
    func setupGame() {
        loadSampleData()
        generateInitialQuest()

        Task {
            try? await loadGameState()
        }
    }

    func loadGameState() async throws {
        if let savedState = try? await firebaseService.loadGameState() {
            gameState.playerStats = savedState.0
            gameState.inventory = savedState.1
        }
    }

    func loadSampleData() {
        // Sample collectables
        collectables = [
            Collectable(id: "shiny1", type: .shiny, position: CGPoint(x: 100, y: 50)),
            Collectable(id: "shiny2", type: .shiny, position: CGPoint(x: -150, y: 100)),
            Collectable(id: "fish1", type: .fish, position: CGPoint(x: 200, y: -80)),
            Collectable(id: "feather1", type: .feather, position: CGPoint(x: -100, y: -100)),
        ]

        // Sample NPCs
        npcs = [
            NPC(id: "crow1", name: "Friendly Crow", animalType: .crow, position: CGPoint(x: 150, y: -50), dialogue: ["Hello little kitty!", "Bring me shinies!"], questsAvailable: [])
        ]

        // Sample interactive objects
        interactiveObjects = [
            InteractiveObject(id: "box1", type: .box, position: CGPoint(x: 50, y: 80)),
            InteractiveObject(id: "trash1", type: .trashCan, position: CGPoint(x: -80, y: 60)),
        ]
    }

    func generateInitialQuest() {
        Task {
            let context = QuestGenerationContext(
                shiniesCollected: gameState.inventory.shinies,
                fishEaten: gameState.playerStats.fishEaten,
                staminaLevel: gameState.playerStats.maxStamina,
                completedQuests: gameState.quests.filter { $0.status == .completed }.count
            )

            do {
                let quest = try await firebaseService.generateQuest(context: context)
                await MainActor.run {
                    gameState.quests.append(quest)
                }
            } catch {
                print("Failed to generate quest: \(error)")
                // Fallback to manual quest
                let fallbackQuest = Quest(
                    id: UUID().uuidString,
                    title: "Welcome to the City!",
                    description: "Explore and collect 5 shinies to get started.",
                    objectives: [QuestObjective(type: .collectShinies, targetAmount: 5, currentProgress: 0)],
                    reward: QuestReward(shinies: 10, feathers: 2, unlockHat: nil),
                    status: .available,
                    npcName: "Friendly Crow",
                    aiGenerated: false
                )
                await MainActor.run {
                    gameState.quests.append(fallbackQuest)
                }
            }
        }
    }

    // MARK: - Input Handling
    func handleCharacterPress(_ characters: String) {
        let char = characters.lowercased()

        switch char {
        case "w":
            catController.moveUp(climbing: catController.isClimbing)
        case "s":
            catController.moveDown()
        case "a":
            catController.moveLeft(running: isShiftPressed)
        case "d":
            catController.moveRight(running: isShiftPressed)
        case "c":
            catController.toggleCrawl()
        case "e":
            interactWithNearbyObject()
        case "q":
            showQuestPanel.toggle()
        case "i":
            showInventory.toggle()
        default:
            break
        }

        checkCollectables()
    }

    func handleSpecialKeyPress(_ key: KeyEquivalent) {
        switch key {
        case .upArrow:
            catController.moveUp(climbing: catController.isClimbing)
        case .downArrow:
            catController.moveDown()
        case .leftArrow:
            catController.moveLeft(running: isShiftPressed)
        case .rightArrow:
            catController.moveRight(running: isShiftPressed)
        case .space:
            catController.jump()
        default:
            break
        }

        checkCollectables()
    }

    // MARK: - Game Logic
    func checkCollectables() {
        for i in 0..<collectables.count {
            if !collectables[i].isCollected && catController.isNearObject(objectPosition: collectables[i].position, threshold: 40) {
                collectables[i].isCollected = true
                gameState.collectItem(collectables[i])

                if collectables[i].type == .fish {
                    gameState.playerStats.eatFish()
                }
            }
        }
    }

    func interactWithNearbyObject() {
        for i in 0..<interactiveObjects.count {
            if catController.isNearObject(objectPosition: interactiveObjects[i].position) {
                interactWith(object: &interactiveObjects[i])
            }
        }
    }

    func interactWith(object: inout InteractiveObject) {
        switch object.type {
        case .box:
            catController.hideInBox()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                catController.exitBox()
            }
        case .trashCan:
            catController.hideInBox()
        case .vase:
            catController.knockOver()
            gameState.playerStats.itemsKnockedOver += 1
        case .person:
            gameState.playerStats.peopleTripped += 1
        case .bird:
            gameState.playerStats.birdsChased += 1
        default:
            break
        }
        object.isInteracted = true
    }

    func findNearbyInteractable() -> String? {
        for object in interactiveObjects where !object.isInteracted {
            if catController.isNearObject(objectPosition: object.position) {
                return "Press E to interact with \(object.type.rawValue)"
            }
        }
        return nil
    }
}

#Preview {
    GameView()
}
