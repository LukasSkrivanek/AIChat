//
//  ProfileView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettingsView: Bool = false
    @State private var showSCreateAvatarView: Bool = false
    @State private var currentUser: UserModel? = .mock
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    @State private var path: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $path) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .navigationDestinationForCoreModule(path: $path)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showSCreateAvatarView) {
                CreateAvatar()
            }
            .task {
                await loadData()
            }
        }
        
    }
    private func loadData() async {
        try? await Task.sleep(for: .seconds(4))
        isLoading = false
        myAvatars = AvatarModel.mocks
    }
    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(currentUser?.profileColorCalculated ?? .accent)
                
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
  
    private var myAvatarsSection: some View {
        Section {
        if myAvatars.isEmpty {
            Group {
                if isLoading {
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
            ForEach(myAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: nil
                )
                .anyButton(.highlight, action: {
                    onAvatarPress(avatar: avatar)
                })
                .removeListRowFormatting()
                
            }
            .onDelete { indexSet in
                onDeleteAvatar(indexSet: indexSet)
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
                            onNewAvatarButtonPressed
                        }
                }
            }
    }
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                onSettingsButtonPressed()
            }
    }
    private var onNewAvatarButtonPressed: () {
        showSCreateAvatarView = true
    }
    private func onSettingsButtonPressed() {
        showSettingsView = true
    }
    private func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        myAvatars.remove(at: index)
    }
    private func onAvatarPress(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
}

#Preview {
    ProfileView()
        .environment(AppState())
}
