//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by macbook on 30.12.2024.
//

import Foundation

struct ChatMessageModel: Identifiable, Equatable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    func hasBeenSeenByCurrentUser(userId: String) -> Bool {
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
    }
    
    static var mock: ChatMessageModel {
        mocks[0]
    }
    
    static var mocks: [ChatMessageModel] {
        [
            .init(
                id: "msg_1",
                chatId: "101",
                authorId: "user_1",
                content: "Hello, how are you?",
                seenByIds: ["user_2", "user_3"],
                dateCreated: Date()
            ),
            .init(
                id: "msg_2",
                chatId: "101",
                authorId: "user_2",
                content: "I'm good, thanks! What about you?",
                seenByIds: ["user_1"],
                dateCreated: Date().addingTimeInterval(hours: -1)
            ),
            .init(
                id: "msg_3",
                chatId: "102",
                authorId: "user_3",
                content: "Can we schedule a meeting for tomorrow?",
                seenByIds: nil,
                dateCreated: Date().addingTimeInterval(hours: -2)
            ),
            .init(
                id: "msg_4",
                chatId: "102",
                authorId: "user_1",
                content: "I am doing well, thanks for asking!",
                seenByIds: ["user_5"],
                dateCreated: Date().addingTimeInterval(hours: -3)
            ),
            .init(
                id: "msg_5",
                chatId: "103",
                authorId: "user_4",
                content: "Let's meet at 3 PM.",
                seenByIds: ["user_5"],
                dateCreated: Date().addingTimeInterval(hours: -4)
            )
        ]
    }
}
