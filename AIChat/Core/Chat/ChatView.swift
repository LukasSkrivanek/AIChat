//
//  ChatView.swift
//  AIChat
//
//  Created by macbook on 07.01.2025.
//

import SwiftUI

struct ChatView: View {
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel? = .mock
    @State private var currentUser: UserModel? = .mock
    @State private var textFieldText: String = ""
    @State private var showChatSettings: Bool = false
    @State private var scrollPosition: String?
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "Chat")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .padding(8)
                    .anyButton {
                        onChatSettingsPress()
                    }
            }
        }
        .confirmationDialog("What would you like to do", isPresented: $showChatSettings) {
            Button("Report User / Chat", role: .destructive) {
                
            }
            
            Button("Delete Chat", role: .destructive) {
                
            }
        } message: {
            Text(" What would you like to do?")
        }
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName
                    )
                    .id(message.id)
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
        .defaultScrollAnchor(.bottom)
        .scrollPosition(id: $scrollPosition,anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
    }
    private var textFieldSection: some View {
        TextField("Say something ...", text: $textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .anyButton(.plain) {
                        onSendMessagePress()
                    }
                    .foregroundStyle(.accent)
                
                , alignment: .trailing
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
                )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
    private func onSendMessagePress() {
        guard let currentUser else { return }
        let content = textFieldText
        let message = ChatMessageModel(
            id: UUID().uuidString,
            chatId: UUID().uuidString,
            authorId: currentUser.userId,
            content: content,
            seenByIds: nil,
            dateCreated: .now
        )

            chatMessages.append(message)
            scrollPosition = message.id

        textFieldText = ""
    }
    private func onChatSettingsPress() {
        showChatSettings = true
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
