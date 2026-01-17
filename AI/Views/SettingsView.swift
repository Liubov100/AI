//
//  SettingsView.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isShowing: Bool
    @ObservedObject var gameState: GameState
    @StateObject private var firebaseService = FirebaseService.shared

    @State private var settings = GameSettings()
    @State private var hasLoadedSettings = false

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }

            // Settings panel
            VStack(spacing: 0) {
                // Header with gradient
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.cyan)
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Audio Settings
                        SettingsSection(title: "Audio", icon: "speaker.wave.2.fill", iconColor: .blue) {
                            VStack(spacing: 14) {
                                VolumeSlider(label: "Master Volume", value: $settings.masterVolume, icon: "speaker.3.fill")
                                VolumeSlider(label: "Music", value: $settings.musicVolume, icon: "music.note")
                                VolumeSlider(label: "Sound Effects", value: $settings.sfxVolume, icon: "waveform")
                            }
                        }

                        // Gameplay Settings
                        SettingsSection(title: "Gameplay", icon: "gamecontroller.fill", iconColor: .purple) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "cat.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.orange)
                                        .frame(width: 20)
                                    Text("Cat Name:")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                    TextField("Enter name", text: $settings.catName)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15))
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.controlBackgroundColor))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                        )
                                        .frame(width: 220)
                                        .onChange(of: settings.catName) { oldValue, newValue in
                                            DispatchQueue.main.async {
                                                gameState.playerStats.catName = newValue
                                            }
                                        }
                                }
                            }
                        }

                        // Graphics Settings
                        SettingsSection(title: "Graphics", icon: "sparkles", iconColor: .yellow) {
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $settings.particleEffects) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.yellow)
                                            .frame(width: 20)
                                        Text("Particle Effects")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                }
                                .toggleStyle(.switch)
                                .tint(.yellow)
                            }
                        }

                        // Controls Info
                        SettingsSection(title: "Controls", icon: "keyboard", iconColor: .green) {
                            VStack(alignment: .leading, spacing: 8) {
                                ControlRow(key: "WASD / Arrows", action: "Move cat")
                                ControlRow(key: "Space", action: "Jump")
                                ControlRow(key: "Shift + Move", action: "Run")
                                ControlRow(key: "C", action: "Crawl")
                                ControlRow(key: "E", action: "Interact")
                                ControlRow(key: "Q", action: "Quests")
                                ControlRow(key: "I", action: "Inventory")
                                ControlRow(key: "Esc", action: "Settings (this menu)")
                            }
                        }

                        // About
                        SettingsSection(title: "About", icon: "info.circle.fill", iconColor: .cyan) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    Text("🐱")
                                        .font(.system(size: 32))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Little Kitty, Big City")
                                            .font(.system(size: 17, weight: .bold))
                                        Text("Recreation")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Divider()
                                    .padding(.vertical, 4)

                                HStack {
                                    Image(systemName: "number")
                                        .foregroundColor(.cyan)
                                        .frame(width: 20)
                                    Text("Version 1.0")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }

                                HStack {
                                    Image(systemName: "hammer.fill")
                                        .foregroundColor(.cyan)
                                        .frame(width: 20)
                                    Text("Built with SwiftUI & Firebase")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(22)
                }
                .background(Color(.windowBackgroundColor).opacity(0.95))
            }
            .frame(width: 640, height: 720)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
        }
        .onAppear {
            loadSettings()
        }
        .onChange(of: settings) { oldValue, newValue in
            saveSettings()
        }
        .onChange(of: isShowing) { oldValue, newValue in
            if !newValue {
                // Save when closing
                saveSettings()
            }
        }
    }

    private func loadSettings() {
        guard !hasLoadedSettings else { return }

        Task {
            if let loadedSettings = try? await firebaseService.loadSettings() {
                await MainActor.run {
                    settings = loadedSettings
                    gameState.playerStats.catName = loadedSettings.catName
                    hasLoadedSettings = true
                }
            } else {
                // Use defaults
                await MainActor.run {
                    settings.catName = gameState.playerStats.catName
                    hasLoadedSettings = true
                }
            }
        }
    }

    private func saveSettings() {
        guard hasLoadedSettings else { return }

        Task {
            try? await firebaseService.saveSettings(settings)
            try? await firebaseService.saveGameState(stats: gameState.playerStats, inventory: gameState.inventory)
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.3), iconColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }

            content
                .padding(.leading, 42)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(iconColor.opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Volume Slider
struct VolumeSlider: View {
    let label: String
    @Binding var value: Double
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
                    .monospacedDigit()
                    .frame(width: 45, alignment: .trailing)
            }

            Slider(value: $value, in: 0...1)
                .tint(.blue)
                .controlSize(.regular)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.windowBackgroundColor).opacity(0.5))
        )
    }
}

// MARK: - Control Row
struct ControlRow: View {
    let key: String
    let action: String

    var body: some View {
        HStack {
            Text(key)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
                .frame(width: 140, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(action)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView(isShowing: .constant(true), gameState: GameState())
}
