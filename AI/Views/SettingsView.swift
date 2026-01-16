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
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(nsColor: .windowBackgroundColor))

                Divider()

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Audio Settings
                        SettingsSection(title: "Audio", icon: "speaker.wave.2.fill") {
                            VStack(spacing: 15) {
                                VolumeSlider(label: "Master Volume", value: $settings.masterVolume, icon: "speaker.3.fill")
                                VolumeSlider(label: "Music", value: $settings.musicVolume, icon: "music.note")
                                VolumeSlider(label: "Sound Effects", value: $settings.sfxVolume, icon: "waveform")
                            }
                        }

                        Divider()

                        // Gameplay Settings
                        SettingsSection(title: "Gameplay", icon: "gamecontroller.fill") {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Cat Name:")
                                        .foregroundColor(.secondary)
                                    TextField("Enter name", text: $settings.catName)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 200)
                                        .onChange(of: settings.catName) { oldValue, newValue in
                                            gameState.playerStats.catName = newValue
                                        }
                                }
                            }
                        }

                        Divider()

                        // Graphics Settings
                        SettingsSection(title: "Graphics", icon: "sparkles") {
                            VStack(alignment: .leading, spacing: 15) {
                                Toggle(isOn: $settings.particleEffects) {
                                    HStack {
                                        Image(systemName: "sparkle")
                                            .foregroundColor(.yellow)
                                        Text("Particle Effects")
                                    }
                                }
                                .toggleStyle(.switch)
                            }
                        }

                        Divider()

                        // Controls Info
                        SettingsSection(title: "Controls", icon: "keyboard") {
                            VStack(alignment: .leading, spacing: 10) {
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

                        Divider()

                        // About
                        SettingsSection(title: "About", icon: "info.circle") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Little Kitty, Big City")
                                    .font(.headline)
                                Text("Recreation")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text("Version 1.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)

                                Text("Built with SwiftUI & Firebase")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                }
                .background(Color(nsColor: .controlBackgroundColor))
            }
            .frame(width: 600, height: 700)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(16)
            .shadow(radius: 20)
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
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            content
                .padding(.leading, 28)
        }
    }
}

// MARK: - Volume Slider
struct VolumeSlider: View {
    let label: String
    @Binding var value: Double
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                    .frame(width: 40, alignment: .trailing)
            }

            Slider(value: $value, in: 0...1)
                .controlSize(.small)
        }
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
