//
//  PlayerNotificationView.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

// MARK: - Player Notification Toast
struct PlayerNotificationToast: View {
    let event: PlayerEvent

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: event.icon)
                .font(.title2)
                .foregroundColor(event.color)
                .frame(width: 40, height: 40)
                .background(event.color.opacity(0.2))
                .clipShape(Circle())

            // Message
            VStack(alignment: .leading, spacing: 4) {
                Text(event.playerName)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)

                Text(event.message)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

// MARK: - Player Activity Feed
struct PlayerActivityFeed: View {
    @ObservedObject var eventManager: PlayerEventManager
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.blue)
                Text("Player Activity")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))

            // Events List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(eventManager.recentEvents.reversed()) { event in
                        PlayerActivityRow(event: event)
                    }

                    if eventManager.recentEvents.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No recent activity")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Player events will appear here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    }
                }
                .padding()
            }
        }
        .frame(width: 350, height: 500)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - Player Activity Row
struct PlayerActivityRow: View {
    let event: PlayerEvent

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: event.icon)
                .foregroundColor(event.color)
                .frame(width: 30, height: 30)
                .background(event.color.opacity(0.2))
                .clipShape(Circle())

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(event.message)
                    .font(.body)

                Text(event.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Activity Feed Button
struct ActivityFeedButton: View {
    @ObservedObject var eventManager: PlayerEventManager
    @Binding var showFeed: Bool

    var body: some View {
        Button(action: { showFeed.toggle() }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .padding(10)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)

                if eventManager.recentEvents.count > 0 {
                    Text("\(eventManager.recentEvents.count)")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 5, y: -5)
                }
            }
        }
    }
}
