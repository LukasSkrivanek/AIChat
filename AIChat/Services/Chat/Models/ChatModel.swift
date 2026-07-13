//
//  ChatModel.swift
//  AIChat
//
//  Created by macbook on 30.12.2024.
//

import Foundation

struct ChatModel: Equatable, Identifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date

    static var mock: ChatModel {
        mocks[0]
    }
    
    static var mocks: [ChatModel] {
        let baseDate = Date(timeIntervalSinceReferenceDate: 1_234_567_890)

        return [
            .init(id: "mock_chat_1", userId: "1", avatarId: "1", dateCreated: baseDate, dateModified: baseDate),
            .init(id: "mock_chat_2", userId: "2", avatarId: "2", dateCreated: baseDate.addingTimeInterval(hours: -1), dateModified: baseDate.addingTimeInterval(minutes: -30)),
            .init(id: "mock_chat_3", userId: "3", avatarId: "3", dateCreated: baseDate.addingTimeInterval(hours: -2), dateModified: baseDate.addingTimeInterval(hours: -4)),
            .init(id: "mock_chat_4", userId: "4", avatarId: "4", dateCreated: baseDate.addingTimeInterval(hours: -3), dateModified: baseDate.addingTimeInterval(hours: -6)),
            .init(id: "mock_chat_5", userId: "5", avatarId: "5", dateCreated: baseDate.addingTimeInterval(hours: -4), dateModified: baseDate.addingTimeInterval(hours: -10))
        ]
    }
}
