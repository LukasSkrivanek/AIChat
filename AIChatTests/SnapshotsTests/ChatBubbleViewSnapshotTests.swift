//
//  ChatBubbleViewSnapshotTests.swift
//  AIChatTests
//
//  Created by macbook on 13.07.2026.
//

import SwiftUI
import Testing
import SnapshotTesting
@testable import AIChat

@MainActor
@Suite(.snapshots(record: .missing))
struct ChatBubbleViewSnapshotTests {

    @Test
    func incomingShortMessage() {
        assertSnapshot(
            of: container(alignment: .leading) {
                ChatBubbleViewBuilder(
                    message: message("Hello there!"),
                    isCurrentUser: false,
                    imageName: nil
                )
            },
            as: .image(layout: .sizeThatFits)
        )
    }

    @Test
    func incomingLongMessage() {
        assertSnapshot(
            of: container(alignment: .leading) {
                ChatBubbleViewBuilder(
                    message: message(
                        "This is a longer incoming message that should wrap across multiple lines so that we protect avatar spacing, bubble padding, and leading alignment."
                    ),
                    isCurrentUser: false,
                    imageName: nil
                )
            },
            as: .image(layout: .sizeThatFits)
        )
    }

    @Test
    func outgoingLongMessage() {
        assertSnapshot(
            of: container(alignment: .trailing) {
                ChatBubbleViewBuilder(
                    message: message(
                        "This is a longer outgoing message that should wrap across multiple lines so that we protect spacing, padding, and bubble width."
                    ),
                    isCurrentUser: true,
                    imageName: nil
                )
            },
            as: .image(layout: .sizeThatFits)
        )
    }

    @ViewBuilder
    private func container<Content: View>(
        alignment: Alignment,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            Color.white
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                .padding(16)
        }
        .frame(width: 390, height: 180)
    }

    private func message(_ content: String) -> ChatMessageModel {
        ChatMessageModel(
            id: "message-id",
            chatId: "chat-id",
            authorId: "author-id",
            content: content,
            seenByIds: [],
            dateCreated: Date(timeIntervalSinceReferenceDate: 0)
        )
    }
}
