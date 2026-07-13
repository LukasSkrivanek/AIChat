//
//  SettingsViewSnapshotTests.swift
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
struct SettingsViewSnapshotTests {

    @Test
    func anonymousUser() {
        assertSnapshot(
            of: makeSettingsView(
                isAnonymousUser: true,
                isPremium: false
            ),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test
    func signedInUser() {
        assertSnapshot(
            of: makeSettingsView(
                isAnonymousUser: false,
                isPremium: true
            ),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    private func makeSettingsView(
        isAnonymousUser: Bool,
        isPremium: Bool
    ) -> SettingsView {
        SettingsView(
            store: Store(
                initialState: SettingsReducer.State(
                    isDeletingAccount: false,
                    isPremium: isPremium,
                    isAnonymousUser: isAnonymousUser
                )
            ) {
                SettingsReducer()
            }
        )
    }
}
