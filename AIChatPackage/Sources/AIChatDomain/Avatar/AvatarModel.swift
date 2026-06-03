import AIChatCommon
import Foundation

public struct AvatarModel: Hashable, Equatable {
    public let avatarId: String
    public let name: String?
    public let characterOption: CharacterOption?
    public let characterAction: CharacterAction?
    public let characterLocation: CharacterLocation?
    public let profileImageName: String?
    public let authorID: String?
    public let dateCreated: Date?

    public init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorID: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorID = authorID
        self.dateCreated = dateCreated
    }

    public var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }

    public static var mock: AvatarModel {
        mocks[0]
    }

    public static var mocks: [AvatarModel] {
        [
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Alpha",
                characterOption: .man,
                characterAction: .smiling,
                characterLocation: .home,
                profileImageName: Constants.randomImage,
                authorID: UUID().uuidString,
                dateCreated: Date()
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Beta",
                characterOption: .woman,
                characterAction: .studying,
                characterLocation: .school,
                profileImageName: Constants.randomImage,
                authorID: UUID().uuidString,
                dateCreated: Date()
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Gamma",
                characterOption: .alien,
                characterAction: .fighting,
                characterLocation: .space,
                profileImageName: Constants.randomImage,
                authorID: UUID().uuidString,
                dateCreated: Date()
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Delta",
                characterOption: .cat,
                characterAction: .relaxing,
                characterLocation: .park,
                profileImageName: Constants.randomImage,
                authorID: UUID().uuidString,
                dateCreated: Date()
            ),
        ]
    }
}
