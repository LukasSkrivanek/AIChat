//
//  ChatView.swift
//  AIChat
//
//  Created by macbook on 07.01.2025.
//

import ComposableArchitecture
import SwiftUI

struct ChatView: View {
    
    @Bindable var store: StoreOf<ChatReducer>

    var body: some View {
            VStack(spacing: 0) {
                scrollViewSection
                textFieldSection
            }
            .navigationTitle(store.avatar?.name ?? "Chat")
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
        .showCustomAlert(alert: $store.alert)
        .showCustomAlert(type: .confirmationDialog, alert: $store.alert)
        .showModal(showModal: $store.showProfileModal) {
            if let avatar  = store.avatar {
                profileModal(avatar: avatar)
            }
               
        }
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(store.chatMessages) { message in
                    let isCurrentUser = message.authorId == store.currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageName: isCurrentUser ? nil : store.avatar?.profileImageName,
                        onnImagePress: {
                            store.send(.toggleProfileModal)
                        }
                    )
                    .id(message.id)
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
        .defaultScrollAnchor(.bottom)
        .scrollPosition(id: $store.scrollPosition, anchor: .center)
        .animation(.default, value: store.chatMessages.count)
        .animation(.default, value: store.scrollPosition)
    }
    private var textFieldSection: some View {
        TextField("Say something ...", text: $store.textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .anyButton(.plain) {
                        store.send(.onSendMessageTapped)
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
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription) {
                store.send(.toggleProfileModal)
            }
            .padding(40)
            .transition(.move(edge: .leading))
    }
    private func onChatSettingsPress() {
        store.alert = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {
                            
                        }
                        Button("Delete Chat", role: .destructive) {
                            
                        }
                    }
                )
            }
        )
    }
}

#Preview {
    NavigationStack {
        ChatView(
            store: Store(
                initialState: ChatReducer.State(
                    chatMessages:
                        ChatMessageModel.mocks,
                    textFieldText: "",
                    scrollPosition: nil,
                    showProfileModal: false,
                    alert: nil
                )
            ) {
                ChatReducer()
            }
        )
    }
}
