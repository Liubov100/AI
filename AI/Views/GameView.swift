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
    @StateObject private var cameraController = CameraController()
    @StateObject private var networkManager = NetworkManager.shared
    @StateObject private var chatManager = ChatManager.shared
    @StateObject private var eventManager = PlayerEventManager.shared
    @StateObject private var firebaseService = FirebaseService.shared
    @StateObject private var tutorialManager = TutorialManager()

    @State private var showQuestPanel = false
    @State private var showInventory = false
    @State private var showHatCustomization = false
    @State private var showSettings = false
    @State private var showChat = false
    @State private var showActivityFeed = false
    @State private var use3DCamera = false
    @State private var collectables: [Collectable] = []
    @State private var npcs: [NPC] = []
    @State private var interactiveObjects: [InteractiveObject] = []
    @State private var isShiftPressed = false
    @State private var showLevelUp = false
    @State private var newLevel = 1
    @State private var previousLevel = 1

    var body: some View {
        ZStack {
            // Full 3D Scene with camera system and network players
            Scene3DView(
                cameraController: cameraController,
                catController: catController,
                networkManager: networkManager,
                collectables: $collectables,
                interactiveObjects: $interactiveObjects
            )
            .ignoresSafeArea()

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
                    VStack(alignment: .trailing, spacing: 10) {
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

                            // Chat Button
                            ChatButtonView(chatManager: chatManager, showChat: $showChat)

                            // Activity Feed Button
                            ActivityFeedButton(eventManager: eventManager, showFeed: $showActivityFeed)
                        }

                        // Camera Mode Picker (always shown now)
                        CameraModePickerView(cameraController: cameraController)
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

            // Chat View
            if showChat {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ChatView(
                            chatManager: chatManager,
                            isShowing: $showChat,
                            localPlayerId: networkManager.localPlayerId,
                            localPlayerName: gameState.playerStats.catName
                        )
                        .padding()
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(999)
            }

            // Activity Feed
            if showActivityFeed {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        PlayerActivityFeed(
                            eventManager: eventManager,
                            isShowing: $showActivityFeed
                        )
                        .padding()
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(998)
            }

            // Tutorial overlay
            if tutorialManager.isActive {
                TutorialOverlayView(tutorial: tutorialManager)
            }

            // Level up celebration
            if showLevelUp {
                LevelUpView(newLevel: newLevel, isShowing: $showLevelUp)
            }

            // Player Event Notification Toast
            if eventManager.showNotification, let event = eventManager.currentNotification {
                VStack {
                    PlayerNotificationToast(event: event)
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

                    // Generate player level up event
                    eventManager.playerLeveledUp(
                        playerName: gameState.playerStats.catName,
                        newLevel: newValue
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
                }
            } catch {
                // Failed to generate AI quest; fallback below
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
            updateCamera()
        case "s":
            catController.moveDown()
            tutorialManager.checkAction(.moveWithWASD)
            updateCamera()
        case "a":
            catController.moveLeft(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
            updateCamera()
        case "d":
            catController.moveRight(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
            updateCamera()
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
            updateCamera()
        case .downArrow:
            catController.moveDown()
            tutorialManager.checkAction(.moveWithWASD)
            updateCamera()
        case .leftArrow:
            catController.moveLeft(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
            updateCamera()
        case .rightArrow:
            catController.moveRight(running: isShiftPressed)
            tutorialManager.checkAction(.moveWithWASD)
            updateCamera()
        case .space:
            catController.jump()
            tutorialManager.checkAction(.pressSpace)
            updateCamera()
        case .escape:
            showSettings.toggle()
            return // Don't check collectables when opening settings
        default:
            break
        }

        checkCollectables()
    }

    // MARK: - Camera Update
    func updateCamera() {
        cameraController.update(
            targetPosition: catController.position,
            facingDirection: catController.facingDirection
        )
    }

    // MARK: - Game Logic
    func checkCollectables() {
        for i in 0..<collectables.count {
            if !collectables[i].isCollected && catController.isNearObject(
                objectPosition: collectables[i].position,
                threshold: GameConfig.Gameplay.collectionRadius
            ) {
                let index = i
                let collectable = collectables[index]

                DispatchQueue.main.async {
                    collectables[index].isCollected = true
                    gameState.collectItem(collectable)

                    if collectable.type == .fish {
                        gameState.playerStats.eatFish()
                    }

                    // Generate player event for collecting item
                    if collectable.type == .shiny {
                        eventManager.playerFoundItem(
                            playerName: gameState.playerStats.catName,
                            itemName: "shiny"
                        )
                    }

                    // Tutorial check
                    tutorialManager.checkAction(.collectItem)
                }

                // Save is already scheduled in gameState.collectItem()
                // No need for additional save here
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

        // Use debounced save from GameState
        gameState.scheduleSave()
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
