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
    @State private var localPlayerId: String
    @State private var localPlayerName: String

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Chat")
                    .font(.title2)
                    .bold()
                Spacer()
                Text("\(chatManager.messages.filter { $0.isAI }.count) AI Players Online")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
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
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            chatManager.markAsRead()
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

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
                        .foregroundColor(isLocalPlayer ? .white : .blue)

                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(isLocalPlayer ? .white.opacity(0.7) : .gray)
                }

                Text(message.message)
                    .font(.body)
                    .padding(10)
                    .background(isLocalPlayer ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isLocalPlayer ? .white : .primary)
                    .cornerRadius(12)
            }

            if !isLocalPlayer {
                Spacer()
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
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)

                if chatManager.unreadCount > 0 {
                    Text("\(chatManager.unreadCount)")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 5, y: -5)
                }
            }
        }
    }
}
