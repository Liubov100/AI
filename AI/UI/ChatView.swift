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
            // Header
            HStack {
                Text("Chat")
                    .font(.title2)
                    .bold()
                    .appTextBackground()
                Spacer()
                Text("\(chatManager.messages.filter { $0.isAI }.count) AI Players Online")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .appTextBackground()
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
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
                .onChange(of: chatManager.messages.count) { _, _ in
                    if let lastMessage = chatManager.messages.last {
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
                        .background(messageText.isEmpty ? Color.gray : Color.blue)
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
        HStack {
            if isLocalPlayer {
                Spacer()
            }

            VStack(alignment: isLocalPlayer ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if !isLocalPlayer && message.isAI {
                        Image(systemName: "cpu")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }

                    Text(message.senderName)
                        .font(.caption)
                        .bold()
                        .foregroundColor(isLocalPlayer ? .black : .blue)

                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(isLocalPlayer ? .black.opacity(0.7) : .gray)
                }

                Text(message.message)
                    .font(.body)
                    .padding(10)
                    .background(isLocalPlayer ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                    .foregroundColor(isLocalPlayer ? .black : .primary)
                    .cornerRadius(12)
            }

            if !isLocalPlayer {
                Spacer()
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
            // Header
            HStack {
                Text("Friends")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))

            // Friends list
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(networkManager.connectedPlayers.filter { $0.isAI }) { player in
                        Button(action: {
                            selectedFriend = (id: player.id, name: player.name)
                            showPrivateChat = true
                        }) {
                            HStack {
                                // Avatar
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(player.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("Lv.\(player.level)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                        Text("Online")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                // Unread badge
                                if chatManager.getUnreadCount(forFriend: player.id, localPlayerId: localPlayerId) > 0 {
                                    Text("\(chatManager.getUnreadCount(forFriend: player.id, localPlayerId: localPlayerId))")
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(.black)
                                        .padding(6)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                            .background(Color(.windowBackgroundColor))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(20)
        .shadow(radius: 10)
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
