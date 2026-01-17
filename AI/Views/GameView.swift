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
    @StateObject private var tutorialManager = TutorialManager.shared

    @State private var showQuestPanel = false
    @State private var showInventory = false
    @State private var showHatCustomization = false
    @State private var showSettings = false
    @State private var showChat = false
    @State private var showActivityFeed = false
    @State private var showFriends = false
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
                        HStack(spacing: 12) {
                            IconButton(
                                icon: "backpack.fill",
                                color: .orange,
                                action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showInventory.toggle()
                                    }
                                }
                            )
                            IconButton(
                                icon: "list.bullet.clipboard.fill",
                                color: .purple,
                                action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showQuestPanel.toggle()
                                    }
                                }
                            )
                            IconButton(
                                icon: "crown.fill",
                                color: .yellow,
                                action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showHatCustomization.toggle()
                                    }
                                }
                            )
                            IconButton(
                                icon: "gearshape.fill",
                                color: .gray,
                                action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        showSettings.toggle()
                                    }
                                }
                            )

                            // Chat Button
                            ChatButtonView(chatManager: chatManager, showChat: $showChat)

                            // Friends Button
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showFriends.toggle()
                                }
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.purple)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [Color.white.opacity(0.3), Color.clear],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                                    if chatManager.getTotalUnreadPrivateMessages() > 0 {
                                        Text("\(chatManager.getTotalUnreadPrivateMessages())")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.purple, .pink],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(color: .purple.opacity(0.5), radius: 3)
                                            .offset(x: 6, y: -6)
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            // Activity Feed Button
                            ActivityFeedButton(eventManager: eventManager, showFeed: $showActivityFeed)
                        }

                        // Camera Mode Picker (always shown now)
                        CameraModePickerView(cameraController: cameraController)
                    }
                }
                .padding()

                // Player Event Notification Toast (placed below collected/stats UI)
                if eventManager.showNotification, let event = eventManager.currentNotification {
                    HStack {
                        Spacer()
                        PlayerNotificationToast(event: event)
                            .frame(maxWidth: 260)
                            .padding(.top, 8)
                            .padding(.trailing, 20)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1500)
                }

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
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }

            // Inventory
            if showInventory {
                InventoryView(inventory: gameState.inventory, isShowing: $showInventory)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }

            // Hat Customization
            if showHatCustomization {
                HatCustomizationView(gameState: gameState, isShowing: $showHatCustomization)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            }

            // Settings
            if showSettings {
                SettingsView(isShowing: $showSettings, gameState: gameState)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
                    .zIndex(1000)
            }

            // Chat View
            if showChat {
                VStack {
                    HStack {
                        Spacer()
                        ChatView(
                            chatManager: chatManager,
                            isShowing: $showChat,
                            localPlayerId: networkManager.localPlayerId,
                            localPlayerName: gameState.playerStats.catName
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 80) // Below the top UI buttons
                    }
                    Spacer()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(999)
            }

            // Activity Feed
            if showActivityFeed {
                VStack {
                    HStack {
                        Spacer()
                        PlayerActivityFeed(
                            eventManager: eventManager,
                            isShowing: $showActivityFeed
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 80) // Below the top UI buttons
                    }
                    Spacer()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(998)
            }

            // Friends List
            if showFriends {
                VStack {
                    HStack {
                        Spacer()
                        FriendsListView(
                            chatManager: chatManager,
                            networkManager: networkManager,
                            isShowing: $showFriends,
                            localPlayerId: networkManager.localPlayerId,
                            localPlayerName: gameState.playerStats.catName
                        )
                        .padding(.trailing, 20)
                        .padding(.top, 80) // Below the top UI buttons
                    }
                    Spacer()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(997)
            }

            // Tutorial overlay
            if tutorialManager.isActive {
                TutorialOverlayView(tutorial: tutorialManager)
            }

            // Level up celebration
            if showLevelUp {
                LevelUpView(newLevel: newLevel, isShowing: $showLevelUp)
            }

            
        }
        .onChange(of: gameState.playerStats.level) { oldValue, newValue in
            DispatchQueue.main.async {
                if newValue > previousLevel {
                    previousLevel = newValue
                    newLevel = newValue
                    showLevelUp = true

                    // Generate player level up event
                    eventManager.playerLeveledUp(level: newValue)
                }
            }
        }
        .focusable()
        .onKeyPress(characters: .alphanumerics) { keyPress in
            // Don't capture input if chat or friends list is open
            guard !showChat && !showFriends else { return .ignored }
            handleCharacterPress(keyPress.characters)
            return .handled
        }
        .onKeyPress(keys: [.upArrow, .downArrow, .leftArrow, .rightArrow, .space, .escape]) { keyPress in
            // Don't capture input if chat or friends list is open (except Escape)
            if (showChat || showFriends) && keyPress.key != .escape {
                return .ignored
            }
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

        Task { @MainActor in
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
    }

    func handleSpecialKeyPress(_ key: KeyEquivalent) {
        Task { @MainActor in
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
                        eventManager.playerFoundItem(itemType: "shiny", count: 1)
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

// MARK: - Icon Button Component
struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameView()
}
