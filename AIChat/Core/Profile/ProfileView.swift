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
    var loadsOnTask: Bool = true

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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
            .sheet(item: $store.scope(state: \.settings, action: \.settings)) { settingsStore in
                SettingsView(store: settingsStore)
            }
            .fullScreenCover(item: $store.scope(state: \.createAvatar, action: \.createAvatar)) { createAvatarStore in
                CreateAvatarView(store: createAvatarStore)
            }
            .task {
                guard loadsOnTask else {
                    return
                }

                store.send(.task)
            }
        } destination: { store in
            switch store.case {
            case .chat(let store):
                ChatView(store: store)
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
                            .frame(maxWidth: .infinity)
                            .removeListRowFormatting()
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
                ForEach(store.myAvatars) { avatar in
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
