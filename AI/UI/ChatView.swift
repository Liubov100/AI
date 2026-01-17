//
//  ChatView.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

// MARK: - Chat View
struct ChatView: View {
    @ObservedObject var chatManager: ChatManager
    @Binding var isShowing: Bool
    @State private var messageText = ""
    let localPlayerId: String
    let localPlayerName: String
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title3)
                    .foregroundColor(.cyan)
                Text("Chat")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("\(chatManager.messages.filter { $0.isAI }.count) Online")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
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

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(chatManager.messages) { message in
                            ChatBubbleView(
                                message: message,
                                isLocalPlayer: message.senderId == localPlayerId
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .background(Color(.windowBackgroundColor).opacity(0.95))
                .onChange(of: chatManager.messages.count) { _, _ in
                    if let lastMessage = chatManager.messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input
            HStack(spacing: 10) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(
                                    messageText.isEmpty ?
                                        LinearGradient(colors: [.gray, .gray], startPoint: .top, endPoint: .bottom) :
                                        LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        )
                        .shadow(color: messageText.isEmpty ? .clear : .blue.opacity(0.3), radius: 4)
                }
                .buttonStyle(.plain)
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
        }
        .frame(width: 420, height: 520)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
        .onAppear {
            chatManager.markAsRead()
            // Auto-focus the text field when chat opens
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        // Chat command: skip tutorial
        if lower == "skip tut." || lower == "skip tut" || lower == "skip tutorial" {
            // Mark tutorial completed and persist
            TutorialManager.shared.skipTutorial()
            LocalStorageService.shared.saveTutorialProgress(completed: true)
        }

        chatManager.sendMessage(
            senderId: localPlayerId,
            senderName: localPlayerName,
            message: messageText,
            isAI: false
        )

        messageText = ""
    }
}

// MARK: - Chat Bubble
struct ChatBubbleView: View {
    let message: ChatMessage
    let isLocalPlayer: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isLocalPlayer {
                Spacer(minLength: 40)
            } else {
                // Avatar for other players
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    if message.isAI {
                        Image(systemName: "cpu")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .blue.opacity(0.3), radius: 2)
            }

            VStack(alignment: isLocalPlayer ? .trailing : .leading, spacing: 4) {
                // Sender name and time
                HStack(spacing: 6) {
                    if !isLocalPlayer && message.isAI {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9))
                            .foregroundColor(.cyan)
                    }

                    Text(message.senderName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(isLocalPlayer ? .blue : .cyan)

                    Text(message.timestamp, style: .time)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)

                // Message bubble
                Text(message.message)
                    .font(.system(size: 14))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                isLocalPlayer ?
                                    LinearGradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                    LinearGradient(colors: [Color(.controlBackgroundColor), Color(.controlBackgroundColor).opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            )
                    )
                    .foregroundColor(isLocalPlayer ? .white : .primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isLocalPlayer ? Color.white.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            }

            if !isLocalPlayer {
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Private Chat View
struct PrivateChatView: View {
    @ObservedObject var chatManager: ChatManager
    @Binding var isShowing: Bool
    @State private var messageText = ""
    let localPlayerId: String
    let localPlayerName: String
    let friendId: String
    let friendName: String
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { isShowing = false }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                Text(friendName)
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(chatManager.getPrivateMessages(withFriend: friendId, localPlayerId: localPlayerId)) { message in
                            ChatBubbleView(
                                message: message,
                                isLocalPlayer: message.senderId == localPlayerId
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatManager.getPrivateMessages(withFriend: friendId, localPlayerId: localPlayerId).count) { _, _ in
                    if let lastMessage = chatManager.getPrivateMessages(withFriend: friendId, localPlayerId: localPlayerId).last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(messageText.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(10)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .frame(width: 400, height: 500)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            chatManager.markPrivateChatAsRead(friendId: friendId, localPlayerId: localPlayerId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        chatManager.sendMessage(
            senderId: localPlayerId,
            senderName: localPlayerName,
            message: messageText,
            isAI: false,
            recipientId: friendId
        )

        messageText = ""
    }
}

// MARK: - Friends List View
struct FriendsListView: View {
    @ObservedObject var chatManager: ChatManager
    @ObservedObject var networkManager: NetworkManager
    @Binding var isShowing: Bool
    @State private var selectedFriend: (id: String, name: String)?
    @State private var showPrivateChat = false
    let localPlayerId: String
    let localPlayerName: String

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.title3)
                    .foregroundColor(.pink)
                Text("Friends")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Friends list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(networkManager.connectedPlayers.filter { $0.isAI }) { player in
                        Button(action: {
                            selectedFriend = (id: player.id, name: player.name)
                            showPrivateChat = true
                        }) {
                            HStack(spacing: 14) {
                                // Avatar with gradient
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 56, height: 56)
                                        .shadow(color: .purple.opacity(0.3), radius: 4)

                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(player.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("Lv.\(player.level)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(
                                                Capsule()
                                                    .fill(Color.purple.opacity(0.7))
                                            )
                                    }

                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                            .shadow(color: .green, radius: 2)
                                        Text("Online")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                // Unread badge
                                if chatManager.getUnreadCount(forFriend: player.id, localPlayerId: localPlayerId) > 0 {
                                    Text("\(chatManager.getUnreadCount(forFriend: player.id, localPlayerId: localPlayerId))")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(7)
                                        .background(
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.red, .pink],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                        .shadow(color: .red.opacity(0.5), radius: 3)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.windowBackgroundColor).opacity(0.95))
        }
        .frame(width: 420, height: 520)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
        .sheet(isPresented: $showPrivateChat) {
            if let friend = selectedFriend {
                PrivateChatView(
                    chatManager: chatManager,
                    isShowing: $showPrivateChat,
                    localPlayerId: localPlayerId,
                    localPlayerName: localPlayerName,
                    friendId: friend.id,
                    friendName: friend.name
                )
            }
        }
    }
}

// MARK: - Chat Button
struct ChatButtonView: View {
    @ObservedObject var chatManager: ChatManager
    @Binding var showChat: Bool

    var body: some View {
        Button(action: {
            showChat.toggle()
            if showChat {
                chatManager.markAsRead()
            }
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title2)
                    .padding(10)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)

                let totalUnread = chatManager.unreadCount + chatManager.getTotalUnreadPrivateMessages()
                if totalUnread > 0 {
                    Text("\(totalUnread)")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.black)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 5, y: -5)
                }
            }
        }
    }
}
