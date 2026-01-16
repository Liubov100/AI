# Little Kitty, Big City - Cat Adventure Game

A SwiftUI-based cat adventure game inspired by "Little Kitty, Big City" with Star Stable Online's UI design, featuring 3D camera system, level progression, and cloud save functionality.

## 🎮 Features

### Core Gameplay
- **Cat Movement System**: WASD/Arrow keys + Shift to run
- **Physics-Based Jumping**: Gravity-based jump mechanics with Space bar
- **Collectibles**: Shinies, fish, feathers, and hats
- **Quest System**: AI-generated and manual quests with objectives
- **Interactive Objects**: Boxes, trash cans, vases, birds to interact with
- **NPC System**: Animals with dialogue and quests

### Level Progression (Star Stable Inspired)
- **XP System**: Exponential scaling (100 + (level-1) × 50)
- **Level Rewards**:
  - +1 Stamina per level (max 10)
  - +50 Jorvik Shillings per level
  - +10 Star Coins every 5 levels
- **Animated Level Up**: Full-screen celebration with rewards

### Dual Currency System
- **Star Coins**: Premium currency (yellow star icon)
- **Jorvik Shillings**: Regular currency (green dollar icon)
- Earned through quests, level ups, and gameplay

### Tutorial System
- 9-step interactive tutorial for new players
- Covers movement, jumping, stats, leveling, collectibles, quests, inventory
- Progress saved to Firebase (won't repeat)
- Skip option available

### 3D Camera System (SceneKit)
4 camera modes:
1. **Follow Behind**: Third-person camera
2. **Follow Above**: Top-down view
3. **Cinematic**: Rotating camera around player
4. **Free**: Manual camera control

Features:
- Smooth camera movement with lerp
- 3D cat model with SceneKit
- 3D collectibles and environment
- Real-time camera mode switching

### Star Stable Inspired UI
- **Level Bar**: Character portrait, name, level, XP progress bar
- **Currency Display**: 4 currencies with icons (Star Coins, Jorvik Shillings, Shinies, Feathers)
- **Notification Toast**: Slide-in notifications with auto-dismiss
- **Level Up Screen**: Animated celebration with rewards breakdown
- **Glassmorphic Design**: Semi-transparent panels with gradients

### Cloud Save (Firebase)
- Auto-save on collectible pickup, quest completion, level up
- Syncs across devices
- Saves:
  - Player stats (level, XP, currencies, stamina)
  - Inventory (shinies, feathers, fish, hats)
  - Quest progress
  - Tutorial progress
  - Settings (volumes, particle effects, cat name)

### AI Quest Generation
- Powered by Firebase Vertex AI (Gemini 1.5 Pro)
- Context-aware quest generation
- Fallback system when AI unavailable
- Auto-save generated quests to Firebase

## 📁 Project Structure

```
AI/
├── Core/              # App entry and root views
├── Models/            # Data models and game state
├── Views/             # Main game views
├── Controllers/       # Game controllers
├── Services/          # Firebase integration
├── Systems/           # Tutorial & Camera systems
└── UI/                # Reusable UI components
```

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed structure.

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- macOS 14.0+
- Firebase account
- Swift Package Manager

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd AI
   ```

2. **Configure Firebase**
   - Follow [SETUP.md](SETUP.md) for detailed Firebase setup
   - Add `GoogleService-Info.plist` to the project
   - Enable Authentication (Anonymous)
   - Enable Firestore Database
   - Enable Vertex AI for Firebase

3. **Install Dependencies**
   - Open `AI.xcodeproj` in Xcode
   - Dependencies will be resolved automatically via SPM

4. **Build and Run**
   - Press `Cmd + R` to build and run
   - Complete the tutorial or skip to start playing

## 🎯 Controls

| Key | Action |
|-----|--------|
| `W` / `↑` | Move up |
| `S` / `↓` | Move down |
| `A` / `←` | Move left |
| `D` / `→` | Move right |
| `Shift + Move` | Run |
| `Space` | Jump |
| `C` | Toggle crawl |
| `E` | Interact with nearby object |
| `Q` | Open quest panel |
| `I` | Open inventory |
| `Esc` | Open settings |

## 🎨 UI Layout

```
┌──────────────────────────────────────────────────────┐
│ ┌───────────────┐               ┌──┐┌──┐┌──┐┌──┐   │
│ │ 🐱 Kitty      │               │🎒││📋││👑││⚙️│   │
│ │ Lvl 5•75/150  │               └──┘└──┘└──┘└──┘   │
│ │ ████████░░░░  │                                   │
│ └───────────────┘                                   │
│ ┌───────────────┐                                   │
│ │ ⭐ 150        │                                   │
│ │ 💰 1,250      │      [3D/2D GAME WORLD]          │
│ │ ✨ 25         │                                   │
│ │ 🍃 10         │          🐱 Cat                  │
│ └───────────────┘      ✨🐟🍃 Collectibles          │
│                                                     │
│                      [CONTROLS HELP]                │
└─────────────────────────────────────────────────────┘
```

## 📊 Progression System

### XP Sources
| Action | XP Gained |
|--------|-----------|
| Collect Shiny | +10 XP |
| Collect Fish | +15 XP |
| Collect Feather | +20 XP |
| Collect Hat | +50 XP |
| Complete Quest | +50 XP + (25 XP × objectives) |

### Level Up Formula
```
XP Required = 100 + (level - 1) × 50

Level 1 → 2: 100 XP
Level 2 → 3: 150 XP
Level 3 → 4: 200 XP
...
```

## 🔥 Firebase Structure

```
Firestore:
├── gameStates/{userId}
│   ├── playerStats: Base64
│   ├── inventory: Base64
│   └── catPosition: {x, y}
│
└── users/{userId}
    ├── quests/
    ├── settings/
    └── progress/
```

## 🛠 Technical Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **3D Engine**: SceneKit
- **Backend**: Firebase
  - Authentication (Anonymous)
  - Firestore Database
  - Vertex AI (Gemini 1.5 Pro)
- **Architecture**: MVVM + ObservableObject
- **Dependency Manager**: Swift Package Manager

## 📦 Dependencies

- `FirebaseAuth` (11.6.0+)
- `FirebaseCore` (11.6.0+)
- `FirebaseFirestore` (11.6.0+)
- `FirebaseVertexAI` (11.6.0+)

## 🎓 Documentation

- [SETUP.md](SETUP.md) - Firebase setup guide
- [FEATURES.md](FEATURES.md) - Detailed feature documentation
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Code organization
- [QUICK_START.md](QUICK_START.md) - Quick start guide
- [CHANGES.md](CHANGES.md) - Version history

## 🎮 Gameplay Tips

1. **Start with the tutorial** - Learn all controls and mechanics
2. **Collect everything** - Items give XP and help with quests
3. **Complete quests** - Best source of XP and currency
4. **Try all camera modes** - Find your favorite view
5. **Customize your cat** - Change the name in settings
6. **Explore the city** - Hidden collectibles everywhere

## 🐛 Known Issues

- Tutorial may show on first launch only
- AI quest generation requires internet and Vertex AI setup
- Camera control in 3D mode is experimental

## 🔮 Future Features

- [ ] More interactive objects
- [ ] Additional NPCs with storylines
- [ ] Hat shop for purchasing cosmetics
- [ ] Fast travel system
- [ ] Multiplayer/leaderboards
- [ ] Sound effects and music
- [ ] More camera angles
- [ ] Day/night cycle

## 👥 Credits

- **Game Design**: Inspired by "Little Kitty, Big City"
- **UI Design**: Inspired by Star Stable Online
- **AI**: Powered by Google Gemini 1.5 Pro
- **Backend**: Firebase by Google

## 📜 License

This is a personal project for educational purposes.

## 🙏 Acknowledgments

- Little Kitty, Big City for the original game concept
- Star Stable Online for UI inspiration
- Firebase for backend infrastructure
- Anthropic Claude for development assistance

---

**Version**: 1.0.0
**Last Updated**: January 16, 2026
**Platform**: macOS 14.0+
**Status**: Active Development
