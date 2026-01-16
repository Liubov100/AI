# Game Features Documentation

## 🎮 New Features Added

### 1. Tutorial System
**Files:** `TutorialSystem.swift`

A comprehensive step-by-step tutorial that guides new players through the game mechanics.

**Features:**
- 9 tutorial steps covering all basic gameplay
- Interactive prompts for movement, jumping, collecting items
- Progress tracking with visual indicators
- Skip tutorial option for returning players
- Automatic start on first launch
- Firebase persistence (won't show again after completion)

**Tutorial Steps:**
1. Welcome message
2. Movement controls (WASD/Arrows)
3. Jumping (Space)
4. Stats panel explanation
5. Level progression system
6. Collectibles overview
7. Quest system (Press Q)
8. Inventory (Press I)
9. Completion

### 2. Level Progression System
**Files:** `Models.swift` (PlayerStats), `StarStableUI.swift` (LevelBarView)

Star Stable Online inspired leveling system with XP and rewards.

**XP Sources:**
- Collect Shiny: +10 XP
- Collect Fish: +15 XP (also restores stamina)
- Collect Feather: +20 XP
- Collect Hat: +50 XP
- Complete Quest: +50 XP base + (25 XP per objective)

**Level Up Rewards:**
- +1 Max Stamina (up to 10)
- +50 Jorvik Shillings per level
- +10 Star Coins every 5 levels
- Celebration screen with animation

**Exponential Scaling:**
```
Level 1 → 2: 100 XP
Level 2 → 3: 150 XP
Level 3 → 4: 200 XP
...
XP Required = 100 + (level - 1) * 50
```

### 3. Currency System (Star Stable Inspired)
**Files:** `Models.swift` (PlayerStats), `StarStableUI.swift` (CurrencyDisplayView)

Two-currency system inspired by Star Stable Online:

**Star Coins (Premium Currency)**
- Starting amount: 100
- Yellow star icon
- Earned through level ups (every 5 levels)
- Used for premium items/features

**Jorvik Shillings (Regular Currency)**
- Starting amount: 500
- Green dollar icon
- Earned through quests and level ups
- Used for regular purchases

**Collectible Resources:**
- Shinies: Orange sparkle icon
- Feathers: Cyan leaf icon (used for fast travel)

### 4. Star Stable Inspired UI Components

#### Level Bar (Top-Left)
- Character portrait with cat emoji
- Cat name display (customizable in settings)
- Current level
- XP progress bar (yellow to orange gradient)
- Real-time XP tracking
- Animated progress updates

#### Currency Display (Below Level Bar)
- 4 currency rows:
  - Star Coins (purple background)
  - Jorvik Shillings (green background)
  - Shinies (orange background)
  - Feathers (cyan background)
- Glassmorphic design
- Real-time updates

#### Notification Toast System
- Slide-in notifications from top
- Auto-dismiss after 3 seconds
- Used for:
  - Item collection
  - Level ups
  - Quest completion
  - Achievements

#### Level Up Celebration Screen
- Full-screen overlay with dark background
- Animated stars around level number
- Reward breakdown
- Yellow glow effects
- Continue button to dismiss

### 5. Firebase Cloud Save System
**Files:** `FirebaseService.swift`

All game data now saved to Firebase for cloud sync across devices.

**Saved Data:**
- Player stats (level, XP, currencies, stamina)
- Inventory (shinies, feathers, fish, hats)
- Quest progress and completion
- Tutorial progress
- Game settings
- Cat position and equipped hat

**New Firebase Methods:**
```swift
// Settings
saveSettings(_ settings: GameSettings) async throws
loadSettings() async throws -> GameSettings?

// Tutorial Progress
saveTutorialProgress(completed: Bool) async throws
loadTutorialProgress() async throws -> Bool

// Game State (overloaded)
saveGameState(stats: PlayerStats, inventory: Inventory) async throws
```

**Auto-Save Triggers:**
- Collecting any item
- Completing a quest
- Leveling up
- Changing settings
- Closing settings panel

### 6. Settings Migration to Firebase
**Files:** `SettingsView.swift`, `StarStableUI.swift` (GameSettings model)

Settings now saved to Firebase instead of local AppStorage for cloud sync.

**Settings Stored:**
- Master Volume (0.0 - 1.0)
- Music Volume (0.0 - 1.0)
- SFX Volume (0.0 - 1.0)
- Particle Effects (on/off)
- Cat Name (synced with PlayerStats)

**Removed:**
- Show FPS toggle (as requested)

## 🎯 Gameplay Flow

### First Time Player:
1. Game loads → Tutorial starts automatically
2. Complete 9 tutorial steps
3. Start playing with level 1, 100 Star Coins, 500 Jorvik Shillings
4. Collect items to gain XP and level up
5. Complete quests for XP, currency, and rewards

### Returning Player:
1. Game loads from Firebase
2. Tutorial skipped (already completed)
3. Progress restored (level, currencies, inventory)
4. Continue playing from where they left off

## 📊 UI Layout

```
┌─────────────────────────────────────────────────────┐
│ ┌─────────────────┐              ┌────┐┌────┐┌────┐│
│ │ 🐱 Kitty        │              │ 🎒 ││ 📋 ││ ⚙️  ││
│ │ Level 5 • 75/150 XP             └────┘└────┘└────┘│
│ │ ████████░░░░░░ (50%)│                             │
│ └─────────────────┘                                 │
│ ┌─────────────────┐                                 │
│ │ ⭐ 150          │                                 │
│ │ 💰 1,250        │                                 │
│ │ ✨ 25           │                                 │
│ │ 🍃 10           │                                 │
│ └─────────────────┘                                 │
│                                                     │
│              [GAME WORLD]                           │
│              🐱 Cat Character                       │
│              ✨ Collectibles                        │
│              🐦 NPCs                                │
│                                                     │
│                    ┌────────────────┐               │
│                    │ Press E to     │               │
│                    │ interact       │               │
│                    └────────────────┘               │
│                                                     │
│              [WASD/Arrows: Move]                    │
│              [Space: Jump]                          │
└─────────────────────────────────────────────────────┘
```

## 🎨 Design Inspiration

The UI takes inspiration from Star Stable Online's older interface (circa 2015-2016):

### Star Stable Elements Used:
1. **Character Card** (top-left with portrait, name, level)
2. **XP Bar** (yellow progress bar showing level progress)
3. **Dual Currency System** (Star Coins + Jorvik Shillings)
4. **Glassmorphic UI** (semi-transparent panels with borders)
5. **Notification Toasts** (temporary pop-ups for events)
6. **Level Up Celebrations** (full-screen with rewards)

### Custom Adaptations:
- Cat theme instead of horses
- City exploration instead of horseback riding
- Collectibles (shinies, feathers) instead of horse equipment
- Simplified UI for desktop/laptop display

## 🔥 Firebase Collections Structure

```
Firestore Database:
├── gameStates/
│   └── {userId}/
│       ├── catPosition: {x, y}
│       ├── playerStats: Base64 encoded PlayerStats
│       ├── inventory: Base64 encoded Inventory
│       ├── equippedHatId: String
│       └── lastUpdated: Timestamp
│
├── users/
│   └── {userId}/
│       ├── quests/
│       │   └── {questId}/
│       │       ├── title, description, objectives...
│       │       └── aiGenerated: Boolean
│       │
│       ├── settings/
│       │   └── gameSettings/
│       │       ├── masterVolume, musicVolume, sfxVolume
│       │       ├── particleEffects
│       │       └── catName
│       │
│       └── progress/
│           └── tutorial/
│               ├── tutorialCompleted: Boolean
│               └── lastUpdated: Timestamp
```

## 🚀 Getting Started

### For Users:
1. Launch game
2. Complete tutorial (or skip if experienced)
3. Move with WASD/Arrow keys
4. Collect items to level up
5. Press Q for quests
6. Press I for inventory
7. Press Esc for settings

### For Developers:
1. Ensure Firebase is configured (see SETUP.md)
2. All new UI components are in `StarStableUI.swift`
3. Tutorial system in `TutorialSystem.swift`
4. Level progression integrated into `Models.swift`
5. Firebase methods in `FirebaseService.swift`

## 📝 Sources

Information about Star Stable Online's UI design was researched from:
- [Star Stable Wiki - User Interface](https://starstable.wiki.gg/wiki/User_Interface)
- [Jorvikipedia - User Interface](https://jorvikipedia.fandom.com/wiki/User_Interface)
- [Star Stable - Horse Progression Update](https://www.starstable.com/en/blog/may-horseprogression-2023)

The game implements a cat-themed adaptation of these design patterns while maintaining the spirit of the original UI aesthetic.
