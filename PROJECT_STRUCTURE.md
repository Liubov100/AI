# Project Structure

## 📁 Organized Folder Structure

```
AI/
├── Core/                           # Application entry and core views
│   ├── AIApp.swift                # App entry point with Firebase initialization
│   └── ContentView.swift          # Root view that loads GameView
│
├── Models/                         # Data models and game state
│   └── Models.swift               # All game models:
│                                    - GameState (game state management)
│                                    - PlayerStats (level, XP, currencies)
│                                    - Inventory (collectibles)
│                                    - Quest (quest system)
│                                    - Collectable, Hat, NPC, etc.
│
├── Views/                          # Main game views
│   ├── GameView.swift             # Main game view with gameplay loop
│   ├── BlackCatView.swift         # 2D cat character view
│   ├── GameObjectViews.swift      # 2D shaped game objects
│   └── SettingsView.swift         # Settings panel
│
├── Controllers/                    # Game controllers
│   └── CatController.swift        # Cat movement and physics
│
├── Services/                       # External services
│   └── FirebaseService.swift      # Firebase integration:
│                                    - Authentication
│                                    - Firestore database
│                                    - AI quest generation
│                                    - Cloud save/load
│
├── Systems/                        # Game systems
│   ├── TutorialSystem.swift       # Tutorial system:
│                                    - TutorialManager
│                                    - TutorialOverlayView
│                                    - Tutorial steps
│   └── CameraSystem.swift         # 3D camera system:
│                                    - CameraController
│                                    - Scene3DView (SceneKit)
│                                    - Camera modes
│
├── UI/                            # UI components
│   ├── StarStableUI.swift         # Star Stable inspired UI:
│   │                                - LevelBarView
│   │                                - CurrencyDisplayView
│   │                                - NotificationToast
│   │                                - LevelUpView
│   │                                - GameSettings model
│   └── UIComponents.swift         # General UI components:
│                                    - StatsPanel
│                                    - QuestPanelView
│                                    - InventoryView
│                                    - HatCustomizationView
│                                    - NPCView
│                                    - CollectableView
│                                    - CityEnvironmentView
│
└── Assets.xcassets/               # Images and assets
    ├── AppIcon.appiconset
    └── AccentColor.colorset
```

## 🎯 File Responsibilities

### Core/
**Purpose:** Application initialization and entry points
- `AIApp.swift`: Firebase setup, app lifecycle
- `ContentView.swift`: Simple wrapper for GameView

### Models/
**Purpose:** All data structures and game state
- Game state management
- Player progression (levels, XP, currencies)
- Quest system data
- Collectibles and inventory
- NPC and interactive object definitions

### Views/
**Purpose:** Main SwiftUI views that render the game
- `GameView.swift`: Main game loop, input handling, game logic (16.7 KB)
- `BlackCatView.swift`: 2D cat sprite built with shapes
- `GameObjectViews.swift`: 2D game objects (shinies, fish, feathers, etc.)
- `SettingsView.swift`: Settings panel with Firebase sync

### Controllers/
**Purpose:** Game logic controllers
- `CatController.swift`: Movement physics, jumping, actions

### Services/
**Purpose:** External service integrations
- `FirebaseService.swift`:
  - Anonymous authentication
  - Cloud save/load
  - AI quest generation with Gemini 1.5 Pro
  - Settings persistence

### Systems/
**Purpose:** Complex game systems
- `TutorialSystem.swift`:
  - 9-step tutorial for new players
  - Progress tracking
  - Interactive tutorial overlay
- `CameraSystem.swift`:
  - 3D camera with 4 modes
  - SceneKit scene rendering
  - 3D cat and object models
  - Smooth camera movement

### UI/
**Purpose:** Reusable UI components
- `StarStableUI.swift`:
  - Level bar with XP progress
  - Currency display (4 currencies)
  - Notification toast system
  - Level up celebration screen
- `UIComponents.swift`:
  - Quest panel
  - Inventory view
  - Hat customization
  - Stats panel
  - City environment

## 📊 Code Statistics

| Category | Files | Purpose |
|----------|-------|---------|
| **Core** | 2 | App entry and initialization |
| **Models** | 1 | Data structures (7.7 KB) |
| **Views** | 4 | Main game rendering (40+ KB) |
| **Controllers** | 1 | Game logic (4.1 KB) |
| **Services** | 1 | Firebase integration (14.5 KB) |
| **Systems** | 2 | Tutorial & Camera (19+ KB) |
| **UI** | 2 | Reusable components (26+ KB) |

**Total Swift Files:** 13
**Total Lines of Code:** ~3,500+ lines

## 🎮 Gameplay Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        User Input                           │
│                     (Keyboard/Mouse)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      GameView.swift                         │
│  - Handles input (WASD, Space, Q, I, Esc)                 │
│  - Updates game state                                       │
│  - Triggers tutorial checks                                 │
└──────┬──────────────────┬───────────────────┬──────────────┘
       │                  │                   │
       ▼                  ▼                   ▼
┌─────────────┐  ┌──────────────────┐  ┌────────────────┐
│CatController│  │   GameState      │  │TutorialManager │
│- Movement   │  │- PlayerStats     │  │- 9 steps       │
│- Physics    │  │- Inventory       │  │- Progress      │
│- Actions    │  │- Quests          │  │- Completion    │
└─────────────┘  └──────┬───────────┘  └────────────────┘
                        │
                        ▼
                ┌──────────────────┐
                │ FirebaseService  │
                │- Auto-save       │
                │- Cloud sync      │
                │- AI quests       │
                └──────────────────┘
```

## 🎨 UI Rendering Flow

```
GameView (Main Container)
│
├── Scene3DView (Optional 3D mode)
│   ├── CameraController (4 modes)
│   ├── 3D Cat Model
│   ├── 3D Collectibles
│   └── 3D Environment
│
├── 2D Game World
│   ├── Background (sky)
│   ├── CityEnvironmentView
│   ├── NPCView (×N)
│   ├── CollectableView (×N)
│   └── BlackCat (player)
│
├── UI Layer (Top)
│   ├── LevelBarView (Star Stable style)
│   ├── CurrencyDisplayView
│   ├── StatsPanel
│   └── Action Buttons (Quest, Inventory, Settings)
│
└── Overlay Panels
    ├── TutorialOverlayView (if active)
    ├── QuestPanelView (if open)
    ├── InventoryView (if open)
    ├── SettingsView (if open)
    ├── LevelUpView (if leveled up)
    └── NotificationToast (temporary)
```

## 🔥 Firebase Data Structure

```
Firestore:
├── gameStates/{userId}
│   ├── playerStats: Base64(PlayerStats)
│   ├── inventory: Base64(Inventory)
│   ├── catPosition: {x, y}
│   └── equippedHatId: String
│
└── users/{userId}
    ├── quests/{questId}
    │   └── Quest data
    │
    ├── settings/gameSettings
    │   ├── volumes
    │   ├── particleEffects
    │   └── catName
    │
    └── progress/tutorial
        └── tutorialCompleted: Bool
```

## 🚀 Key Features by File

| File | Key Features |
|------|--------------|
| **GameView.swift** | Input handling, game loop, collectibles, tutorial integration, level up detection, notifications |
| **TutorialSystem.swift** | 9-step tutorial, progress tracking, interactive prompts, Firebase persistence |
| **CameraSystem.swift** | 4 camera modes, 3D SceneKit rendering, smooth camera movement, 3D models |
| **StarStableUI.swift** | Level bar, currency display, notifications, level up celebration, MMO-style UI |
| **FirebaseService.swift** | Cloud save/load, AI quest generation, settings sync, tutorial progress |
| **Models.swift** | Level progression, XP system, dual currencies, quest system |

## 📝 Development Guidelines

### Adding New Features:
1. **Models** → Add data structures in `Models/`
2. **Views** → Add SwiftUI views in `Views/`
3. **UI Components** → Add reusable UI in `UI/`
4. **Systems** → Add complex systems in `Systems/`
5. **Services** → Add external integrations in `Services/`

### Code Organization:
- Keep views focused and under 300 lines
- Extract reusable components to `UI/`
- Put game systems in `Systems/`
- All data models in `Models/`
- External services in `Services/`

This structure makes it easy to:
- Find specific functionality
- Maintain and update code
- Add new features without conflicts
- Understand the codebase at a glance
