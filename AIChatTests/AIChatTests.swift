//
//  AIChatTests.swift
//  AIChatTests
//
//  Created by macbook on 16.12.2024.
//

import AIChatDomain
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
        let firstUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let secondUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

        let store = TestStore(
            initialState: ChatReducer.State(
                textFieldText: "Hi SwiftTesting",
                currentUser: user
            ),
            reducer: { ChatReducer()
            }, withDependencies: {
                var uuids = [firstUUID, secondUUID].makeIterator()
                $0.uuid = .init {
                    uuids.next()!
                }
                $0.date.now = Date(timeIntervalSinceReferenceDate: 1976)
            }
        )

        await store.send(.onSendMessageTapped) {
            $0.chatMessages = [
                ChatMessageModel(
                    id: firstUUID.uuidString,
                    chatId: secondUUID.uuidString,
                    authorId: user.userId,
                    content: "Hi SwiftTesting",
                    seenByIds: nil,
                    dateCreated: Date(timeIntervalSinceReferenceDate: 1976)
                )
            ]
            $0.textFieldText = ""
            $0.scrollPosition = firstUUID.uuidString
        }

        #expect(store.state.chatMessages.count == 1)
        #expect(store.state.chatMessages.first?.content == "Hi SwiftTesting")
        #expect(store.state.scrollPosition == store.state.chatMessages.first?.id)
    }
}
