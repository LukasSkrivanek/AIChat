//
//  ProfileViewSnapshotTests.swift
//  AIChatTests
//
//  Created by macbook on 13.07.2026.
//

import SwiftUI
import Testing
import SnapshotTesting
import ComposableArchitecture
@testable import AIChat

@MainActor
@Suite(.snapshots(record: .missing))
struct ProfileViewSnapshotTests {

    @Test
    func emptyState() {
        assertSnapshot(
            of: makeProfileView(
                avatars: []
            ),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test
    func loadedState() {
        assertSnapshot(
            of: makeProfileView(
                avatars: [
                    .init(
                        avatarId: "avatar-alpha",
                        name: "Alpha",
                        characterOption: .man,
                        characterAction: .smiling,
                        characterLocation: .home,
                        profileImageName: nil
                    ),
                    .init(
                        avatarId: "avatar-beta",
                        name: "Beta",
                        characterOption: .alien,
                        characterAction: .working,
                        characterLocation: .space,
                        profileImageName: nil
                    )
                ]
            ),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    private func makeProfileView(
        avatars: [AvatarModel]
    ) -> ProfileView {
        ProfileView(
            store: Store(
                initialState: ProfileReducer.State(
                    currentUser: .init(
                        userId: "user-profile",
                        isAnonymous: false,
                        didCompleteOnboarding: true,
                        profileColorHex: "#33FF57"
                    ),
                    isLoading: false,
                    myAvatars: avatars
                )
            ) {
                ProfileReducer()
            },
            loadsOnTask: false
        )
    }
}
