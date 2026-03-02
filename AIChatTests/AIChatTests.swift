//
//  AIChatTests.swift
//  AIChatTests
//
//  Created by macbook on 16.12.2024.
//

import SwiftUI
import Testing
import ComposableArchitecture
@testable import AIChat

@Suite("ChatReducer tests")
struct AIChatTests {

    @Test
    func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test
    func testSendMessageSuccess() async {
        let user = UserModel.mock
        let store = TestStore(
            initialState: ChatReducer.State(
                chatMessages: [],
                textFieldText: "Hi SwiftTesting",
                scrollPosition: nil,
                showProfileModal: false,
                alert: nil,
                currentUser: user,
                avatar: .mock,
                avatarId: AvatarModel.mock.avatarId
            ),
            reducer: { ChatReducer()
            }, withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSinceReferenceDate: 1976)
            }
        )

        store.exhaustivity = .off
        await store.send(.onSendMessageTapped)

        #expect(store.state.chatMessages.count == 1)
        #expect(store.state.chatMessages.first?.content == "Hi SwiftTesting")
        #expect(store.state.scrollPosition == store.state.chatMessages.first?.id)
    }
}
