//
//  ProfileView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {

    @Bindable var store: StoreOf<ProfileReducer>

    var body: some View {
        NavigationStack {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
            .sheet(item: $store.scope(state: \.destination?.settings, action: \.destination.settings)) { settingsStore in
                SettingsView(store: settingsStore)
            }
            .fullScreenCover(item: $store.scope(state: \.destination?.createAvatar, action: \.destination.createAvatar)) { _ in
                CreateAvatar()
            }
            .navigationDestination(item: $store.scope(state: \.destination?.chat, action: \.destination.chat)) { chatStore in
                ChatView(store: chatStore)
            }
            .task {
                store.send(.task)
            }
        }
    }

    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(store.currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }

    private var myAvatarsSection: some View {
        Section {
            if store.myAvatars.isEmpty {
                Group {
                    if store.isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                            .padding(50)
                            .frame(maxWidth: .infinity)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .removeListRowFormatting()
                    }
                }
            } else {
                ForEach(store.myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight, action: {
                        store.send(.avatarTapped(avatar))
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    store.send(.deleteAvatar(indexSet))
                }
            }
        } header: {
            HStack(spacing: 0) {
                Text("My Avatar")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        store.send(.newAvatarButtonTapped)
                    }
            }
        }
    }

    private var settingsButton: some View {
        ZStack {
            Color.clear
            Image(systemName: "gear")
                .font(.headline)
                .foregroundStyle(.accent)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .clipped()
        .background(Color.clear)
            .anyButton {
                store.send(.settingsButtonTapped)
            }
    }
}

#Preview {
    ProfileView(
        store: Store(initialState: ProfileReducer.State()) {
            ProfileReducer()
        }
    )
}
