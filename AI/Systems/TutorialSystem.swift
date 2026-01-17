//
//  TutorialSystem.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI
import Combine

// MARK: - Tutorial Models
struct TutorialStep: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let highlightArea: TutorialHighlight?
    let action: TutorialAction

    enum TutorialHighlight: String, Codable {
        case catCharacter
        case statsPanel
        case questButton
        case inventoryButton
        case controls
        case collectibles
        case levelBar
    }

    enum TutorialAction: String, Codable {
        case tapToContinue
        case moveWithWASD
        case pressQ
        case pressI
        case collectItem
        case pressSpace
        case completed
    }
}

class TutorialManager: ObservableObject {
    static let shared = TutorialManager()
    @Published var isActive = false
    @Published var currentStepIndex = 0
    @Published var completedSteps: Set<String> = []
    @Published var tutorialCompleted = false

    let steps: [TutorialStep] = [
        TutorialStep(
            id: "welcome",
            title: "Welcome to Little Kitty, Big City!",
            message: "You're a curious black cat exploring the city. Let's learn the basics!",
            highlightArea: .catCharacter,
            action: .tapToContinue
        ),
        TutorialStep(
            id: "movement",
            title: "Cat Movement",
            message: "Use WASD or Arrow Keys to move around. Hold Shift while moving to run faster!",
            highlightArea: .controls,
            action: .moveWithWASD
        ),
        TutorialStep(
            id: "jump",
            title: "Jumping",
            message: "Press SPACE to jump over obstacles and reach higher places.",
            highlightArea: .catCharacter,
            action: .pressSpace
        ),
        TutorialStep(
            id: "stats",
            title: "Your Stats",
            message: "This panel shows your level, XP, and collected items. Complete quests to level up!",
            highlightArea: .statsPanel,
            action: .tapToContinue
        ),
        TutorialStep(
            id: "levelSystem",
            title: "Level Progression",
            message: "The yellow bar shows your XP progress. Collect items and complete quests to gain XP and level up!",
            highlightArea: .levelBar,
            action: .tapToContinue
        ),
        TutorialStep(
            id: "collectibles",
            title: "Collectibles",
            message: "Find and collect shinies, fish, and feathers around the city. Walk near them to pick them up!",
            highlightArea: .collectibles,
            action: .collectItem
        ),
        TutorialStep(
            id: "quests",
            title: "Quest System",
            message: "Press Q to open your quest panel. Complete quests to earn rewards and unlock new areas!",
            highlightArea: .questButton,
            action: .pressQ
        ),
        TutorialStep(
            id: "inventory",
            title: "Inventory",
            message: "Press I to check your collected items and equipped hat.",
            highlightArea: .inventoryButton,
            action: .pressI
        ),
        TutorialStep(
            id: "complete",
            title: "You're Ready!",
            message: "Great job! Now go explore the city and complete quests. Have fun!",
            highlightArea: nil,
            action: .completed
        )
    ]

    var currentStep: TutorialStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    func startTutorial() {
        isActive = true
        currentStepIndex = 0
    }

    func nextStep() {
        if let current = currentStep {
            completedSteps.insert(current.id)
        }

        currentStepIndex += 1

        if currentStepIndex >= steps.count {
            completeTutorial()
        }
    }

    func skipTutorial() {
        completeTutorial()
    }

    func completeTutorial() {
        tutorialCompleted = true
        isActive = false

        // Save to Firebase
        Task {
            try? await FirebaseService.shared.saveTutorialProgress(completed: true)
        }
    }

    func checkAction(_ action: TutorialStep.TutorialAction) {
        if currentStep?.action == action {
            nextStep()
        }
    }
}

// MARK: - Tutorial Overlay View
struct TutorialOverlayView: View {
    @ObservedObject var tutorial: TutorialManager

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Tutorial message box
            if let step = tutorial.currentStep {
                VStack(spacing: 20) {
                    // Title
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        Text(step.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .appTextBackground()
                        Spacer()
                    }

                    // Message
                    Text(step.message)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appTextBackground()

                    // Action indicator
                    HStack {
                        actionIndicator(for: step.action)
                        Spacer()
                    }

                    // Buttons
                    HStack(spacing: 15) {
                        if step.action == .tapToContinue || step.action == .completed {
                            Button(action: {
                                if step.action == .completed {
                                    tutorial.completeTutorial()
                                } else {
                                    tutorial.nextStep()
                                }
                            }) {
                                Text(step.action == .completed ? "Start Playing!" : "Continue")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }

                        Button(action: {
                            tutorial.skipTutorial()
                        }) {
                            Text("Skip Tutorial")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }

                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<tutorial.steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == tutorial.currentStepIndex ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(30)
                .frame(maxWidth: 500)
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(16)
                .shadow(radius: 20)
            }
        }
        .zIndex(2000)
    }

    @ViewBuilder
    private func actionIndicator(for action: TutorialStep.TutorialAction) -> some View {
        HStack(spacing: 8) {
            switch action {
            case .moveWithWASD:
                Image(systemName: "arrow.up.arrow.down.arrow.left.arrow.right")
                    .foregroundColor(.blue)
                Text("Try moving with WASD or Arrow Keys")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .pressQ:
                Text("Q")
                    .font(.system(.body, design: .monospaced))
                    .padding(6)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
                Text("Press Q to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .pressI:
                Text("I")
                    .font(.system(.body, design: .monospaced))
                    .padding(6)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
                Text("Press I to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .pressSpace:
                Text("SPACE")
                    .font(.system(.body, design: .monospaced))
                    .padding(6)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
                Text("Press Space to jump")
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .collectItem:
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Walk near a shiny to collect it")
                    .font(.caption)
                    .foregroundColor(.secondary)
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    TutorialOverlayView(tutorial: TutorialManager())
}
