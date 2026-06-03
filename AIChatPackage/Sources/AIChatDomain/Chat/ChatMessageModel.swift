import AIChatCommon
import Foundation

public struct ChatMessageModel: Identifiable, Equatable {
    public let id: String
    public let chatId: String
    public let authorId: String?
    public let content: String?
    public let seenByIds: [String]?
    public let dateCreated: Date?

    public init(
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

    public func hasBeenSeenByCurrentUser(userId: String) -> Bool {
        guard let seenByIds else {
            return false
        }
        return seenByIds.contains(userId)
    }

    public static var mock: ChatMessageModel {
        mocks[0]
    }

    public static var mocks: [ChatMessageModel] {
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
            ),
        ]
    }
}
