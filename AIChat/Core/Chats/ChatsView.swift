//
//  ChatsView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI
import ComposableArchitecture

struct ChatsView: View {
    @Bindable var store: StoreOf<ChatsReducer>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                if !store.recentAvatars.isEmpty {
                    recentSection
                }

                chatSection
            }
            .navigationTitle("Chats")
        } destination: { store in
            switch store.case {
            case let .chat(store):
                ChatView(store: store)
            }
        }
    }

    private var recentSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(store.recentAvatars, id: \.self) { avatar in
                        if let imageName =  avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton {
                                store.send(.avatarTapped(avatar))
                            }
                        }
                    }
                }
                .padding(.top, 12)
            
            }
            .frame(height: 120)
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }

    private var chatSection: some View {
        Section {
            if store.chats.isEmpty {
                Text("Your chats will appear here")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(store.chats) { chat in
                    ChatRoCellViewBuilder(
                        currentUserId: nil,
                        chat: chat) {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        } getChatMessage: {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        }
                        .anyButton(.highlight) {
                            store.send(.chatTapped(chat))
                        }
                        .removeListRowFormatting()
                }
            }
        } header: {
            Text("Chats")
        }
    }
}

#Preview {
    ChatsView(
        store: Store(initialState: ChatsReducer.State()) {
            ChatsReducer()
        }
    )
}
