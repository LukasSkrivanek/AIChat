import AIChatCommon
import Foundation

public struct ChatModel: Identifiable {
    public let id: String
    public let userId: String
    public let avatarId: String
    public let dateCreated: Date
    public let dateModified: Date

    public init(
        id: String,
        userId: String,
        avatarId: String,
        dateCreated: Date,
        dateModified: Date
    ) {
        self.id = id
        self.userId = userId
        self.avatarId = avatarId
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }

    public static var mock: ChatModel {
        mocks[0]
    }

    public static var mocks: [ChatModel] {
        [
            .init(id: "mock_chat_1", userId: "1", avatarId: "1", dateCreated: Date(), dateModified: Date()),
            .init(id: "mock_chat_2", userId: "2", avatarId: "2", dateCreated: Date().addingTimeInterval(hours: -1), dateModified: Date().addingTimeInterval(minutes: -30)),
            .init(id: "mock_chat_3", userId: "3", avatarId: "3", dateCreated: Date().addingTimeInterval(hours: -2), dateModified: Date().addingTimeInterval(hours: -4)),
            .init(id: "mock_chat_4", userId: "4", avatarId: "4", dateCreated: Date().addingTimeInterval(hours: -3), dateModified: Date().addingTimeInterval(hours: -6)),
            .init(id: "mock_chat_5", userId: "5", avatarId: "5", dateCreated: Date().addingTimeInterval(hours: -4), dateModified: Date().addingTimeInterval(hours: -10)),
        ]
    }
}
