//
//  GameView.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI
import SceneKit

struct GameView: View {
    @StateObject private var gameState = GameState()
    @StateObject private var catController = CatController()
    @StateObject private var firebaseService = FirebaseService.shared
    @StateObject private var tutorialManager = TutorialManager()

    @State private var showQuestPanel = false
    @State private var showInventory = false
    @State private var showHatCustomization = false
    @State private var showSettings = false
    @State private var collectables: [Collectable] = []
    @State private var npcs: [NPC] = []
    @State private var interactiveObjects: [InteractiveObject] = []
    @State private var isShiftPressed = false
    @State private var showLevelUp = false
    @State private var newLevel = 1
    @State private var showNotification = false
    @State private var notificationTitle = ""
    @State private var notificationMessage = ""
    @State private var notificationIcon = "checkmark.circle.fill"
    @State private var notificationColor = Color.green
    @State private var previousLevel = 1

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.8, green: 0.9, blue: 1.0)
                .ignoresSafeArea()

            // 3D Scene (SceneKit)
            SceneKitView(
                collectables: $collectables,
                npcs: $npcs,
                interactiveObjects: $interactiveObjects,
                catPosition: Binding(get: { catController.position }, set: { catController.position = $0 })
            )

            // City Environment (2D fallback/overlay)
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
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        // New Star Stable inspired level bar
                        LevelBarView(gameState: gameState)

                        // Currency display
                        CurrencyDisplayView(gameState: gameState)

                        // Old stats panel (can remove if you prefer just the level bar)
                        StatsPanel(gameState: gameState)
                    }
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
                        Button(action: { showSettings.toggle() }) {
                            Image(systemName: "gearshape.fill")
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

            // Settings
            if showSettings {
                SettingsView(isShowing: $showSettings, gameState: gameState)
                    .transition(.opacity)
                    .zIndex(1000)
            }

            // Tutorial overlay
            if tutorialManager.isActive {
                TutorialOverlayView(tutorial: tutorialManager)
            }

            // Level up celebration
            if showLevelUp {
                LevelUpView(newLevel: newLevel, isShowing: $showLevelUp)
            }

            // Notification toast
            if showNotification {
                VStack {
                    NotificationToast(
                        title: notificationTitle,
                        message: notificationMessage,
                        icon: notificationIcon,
                        iconColor: notificationColor,
                        isShowing: $showNotification
                    )
                    .padding(.top, 20)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1500)
            }
        }
        .onChange(of: gameState.playerStats.level) { oldValue, newValue in
            DispatchQueue.main.async {
                if newValue > previousLevel {
                    previousLevel = newValue
                    newLevel = newValue
                    showLevelUp = true
                    showNotificationMessage(
                        title: "Level Up!",
                        message: "You reached level \(newValue)!",
                        icon: "star.fill",
                        color: .yellow
                    )
                }
            }
        }
        .focusable()
        .onKeyPress(characters: .alphanumerics) { keyPress in
            handleCharacterPress(keyPress.characters)
            return .handled
        }
        .onKeyPress(keys: [.upArrow, .downArrow, .leftArrow, .rightArrow, .space, .escape]) { keyPress in
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
        previousLevel = gameState.playerStats.level

        Task {
            try? await loadGameState()

            // Check if tutorial should start
            if let tutorialCompleted = try? await firebaseService.loadTutorialProgress() {
                if !tutorialCompleted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        tutorialManager.startTutorial()
                    }
                }
            } else {
                // First time player, start tutorial
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    tutorialManager.startTutorial()
                }
            }
        }
    }

    func loadGameState() async throws {
        if let savedState = try? await firebaseService.loadGameState() {
            await MainActor.run {
                gameState.playerStats = savedState.0
                gameState.inventory = savedState.1
            }
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

                // Save AI-generated quest to Firebase
                if quest.aiGenerated {
                    try? await firebaseService.saveQuest(quest)
                    print("✅ AI quest saved to Firebase: \(quest.title)")
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
            tutorialManager.checkAction(.moveWithWASD)
        case "s":
            catController.moveDown()
            tutorialManager.checkAction(.moveWithWASD)
        case "a":
            catController.moveLeft(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
        case "d":
            catController.moveRight(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
        case "c":
            catController.toggleCrawl()
        case "e":
            interactWithNearbyObject()
        case "q":
            showQuestPanel.toggle()
            tutorialManager.checkAction(.pressQ)
        case "i":
            showInventory.toggle()
            tutorialManager.checkAction(.pressI)
        default:
            break
        }

        checkCollectables()
    }

    func handleSpecialKeyPress(_ key: KeyEquivalent) {
        switch key {
        case .upArrow:
            catController.moveUp(climbing: catController.isClimbing)
            tutorialManager.checkAction(.moveWithWASD)
        case .downArrow:
            catController.moveDown()
            tutorialManager.checkAction(.moveWithWASD)
        case .leftArrow:
            catController.moveLeft(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
        case .rightArrow:
            catController.moveRight(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
        case .space:
            catController.jump()
            tutorialManager.checkAction(.pressSpace)
        case .escape:
            showSettings.toggle()
            return // Don't check collectables when opening settings
        default:
            break
        }

        checkCollectables()
    }

    // MARK: - Game Logic
    func checkCollectables() {
        for i in 0..<collectables.count {
            if !collectables[i].isCollected && catController.isNearObject(objectPosition: collectables[i].position, threshold: 40) {
                let index = i
                let collectable = collectables[index]

                DispatchQueue.main.async {
                    collectables[index].isCollected = true
                    gameState.collectItem(collectable)

                    if collectable.type == .fish {
                        gameState.playerStats.eatFish()
                    }

                    // Show notification for collectible
                    let itemName = collectable.type.rawValue.capitalized
                    showNotificationMessage(
                        title: "Collected!",
                        message: "You found a \(itemName)!",
                        icon: iconForCollectable(collectable.type),
                        color: colorForCollectable(collectable.type)
                    )

                    // Tutorial check
                    tutorialManager.checkAction(.collectItem)
                }

                // Save progress to Firebase (can run outside the deferred UI mutation)
                Task {
                    try? await firebaseService.saveGameState(
                        stats: gameState.playerStats,
                        inventory: gameState.inventory
                    )
                }
            }
        }
    }

    func showNotificationMessage(title: String, message: String, icon: String, color: Color) {
        notificationTitle = title
        notificationMessage = message
        notificationIcon = icon
        notificationColor = color

        withAnimation {
            showNotification = true
        }

        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showNotification = false
            }
        }
    }

    func iconForCollectable(_ type: CollectableType) -> String {
        switch type {
        case .shiny: return "sparkles"
        case .fish: return "fish.fill"
        case .feather: return "leaf.fill"
        case .hat: return "crown.fill"
        }
    }

    func colorForCollectable(_ type: CollectableType) -> Color {
        switch type {
        case .shiny: return .yellow
        case .fish: return .blue
        case .feather: return .green
        case .hat: return .purple
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
            Task {
                try? await firebaseService.saveGameState(stats: gameState.playerStats, inventory: gameState.inventory)
            }
        case .person:
            gameState.playerStats.peopleTripped += 1
            Task {
                try? await firebaseService.saveGameState(stats: gameState.playerStats, inventory: gameState.inventory)
            }
        case .bird:
            gameState.playerStats.birdsChased += 1
            Task {
                try? await firebaseService.saveGameState(stats: gameState.playerStats, inventory: gameState.inventory)
            }
        default:
            break
        }
        object.isInteracted = true
        Task {
            try? await firebaseService.saveGameState(stats: gameState.playerStats, inventory: gameState.inventory)
        }
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
