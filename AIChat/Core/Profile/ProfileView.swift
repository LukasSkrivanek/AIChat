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
        NavigationStack(
            path: Binding(
                get: { store.path },
                set: { store.send(.pathChanged($0)) }
            )
        ) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .navigationDestinationForCoreModule(
                path: Binding(
                    get: { store.path },
                    set: { store.send(.pathChanged($0)) }
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
            .sheet(item: $store.scope(state: \.settings, action: \.settings)) { settingsStore in
                SettingsView(store: settingsStore)
            }
            .fullScreenCover(
                isPresented: Binding(
                    get: { store.showCreateAvatar },
                    set: { if !$0 { store.send(.createAvatarDismissed) } }
                )
            ) {
                CreateAvatar()
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
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
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
