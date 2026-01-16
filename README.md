# Little Kitty, Big City - Game Recreation

A SwiftUI-based recreation of "Little Kitty, Big City" with Firebase integration and AI-powered quest generation.

## Features Implemented

### ✅ Core Gameplay
- **Cat Movement System**
  - WASD/Arrow keys for movement
  - Space for jumping
  - C for crawling
  - Shift + movement for running
  - Climbing mechanics (requires stamina)

### ✅ Collectibles System
- **Shinies** ⭐ - Currency for unlocking hats
- **Fish** 🐟 - Increases stamina when eaten (max 4 stamina bars)
- **Feathers** 🍃 - Used for fast travel
- **Hats** 👑 - Cosmetic customization unlocked with shinies

### ✅ Quest System
- AI-generated quests using Firebase Vertex AI (Gemini)
- Multiple quest types:
  - Collect shinies
  - Collect feathers
  - Find fish
  - Knock over items
  - Trip people
  - Chase birds
  - Visit locations
  - Talk to NPCs
- Quest statuses: Available, Active, Ready to Complete, Completed
- Rewards system with shinies and feathers

### ✅ Cat Behaviors
- Jump into boxes
- Hide in trash cans
- Knock over objects
- Steal food
- Trip people
- Chase birds
- Various cat animations and states

### ✅ Progression System
- Stamina system (unlocked by eating fish)
- Player statistics tracking:
  - Fish eaten
  - Birds chased
  - Items knocked over
  - People tripped

### ✅ UI Features
- Stats panel (shinies, feathers, fish, stamina)
- Quest panel with AI generation
- Inventory view
- Hat customization shop
- Action hints for nearby interactables
- Controls help overlay

### ✅ Firebase Integration
- **Authentication**: Anonymous sign-in
- **Firestore**: Save/load game states and quests
- **Vertex AI**: AI-powered quest generation using Gemini

### ✅ NPCs & World
- Various animal NPCs (crow, dog, duck, pigeon, squirrel, rat)
- Interactive objects (boxes, trash cans, vases, people, birds)
- Simple city environment with buildings

### ⏳ Planned Features
- Fast travel system (requires feathers)
- More complex city layouts
- More hat designs
- Sound effects and music
- Advanced climbing mechanics
- Weather system

## Firebase Setup Required

Before running the game, you need to enable these Firebase services:

1. **Firebase Authentication**
   - Enable Anonymous Authentication

2. **Cloud Firestore**
   - Create database in test mode

3. **Vertex AI in Firebase**
   - Enable Gemini API for quest generation

4. **Add GoogleService-Info.plist**
   - Download from Firebase Console
   - Add to Xcode project

## Controls

| Key | Action |
|-----|--------|
| WASD / Arrow Keys | Move cat |
| Space | Jump |
| C | Toggle crawl |
| E | Interact with nearby objects |
| Q | Toggle quest panel |
| I | Toggle inventory |
| Shift + Move | Run |

## Architecture

```
Models.swift          - Game data models (Quest, Collectable, GameState, etc.)
FirebaseService.swift - Firebase integration and AI quest generation
CatController.swift   - Cat movement and action controller
GameView.swift        - Main game view and logic
UIComponents.swift    - All UI components (panels, cards, views)
ContentView.swift     - Entry point
```

## AI Quest Generation

The game uses Firebase Vertex AI (Gemini) to generate dynamic quests based on:
- Current player progress
- Shinies collected
- Fish eaten
- Stamina level
- Completed quests

Each generated quest includes:
- Creative title
- Fun description
- Appropriate objectives
- Balanced rewards
- Optional NPC assignment

## Game Loop

1. Player explores the city as a cat
2. Collects shinies, fish, and feathers
3. Completes quests (manual or AI-generated)
4. Unlocks hats with earned shinies
5. Increases stamina by eating fish
6. Interacts with NPCs and objects
7. Game state auto-saves to Firebase

## Development Notes

- Built with SwiftUI for macOS
- Uses Combine for reactive state management
- Firebase SDK integration
- Async/await for network calls
- Observable objects for game state

## Future Enhancements

- Procedural city generation
- More cat animations
- Multiplayer (see other cats in the city)
- More animal species
- Daily challenges
- Achievements system
- Leaderboards
