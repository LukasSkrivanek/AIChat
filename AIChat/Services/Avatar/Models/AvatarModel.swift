//
//  AvatarModel.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//
import Foundation

// imutable struct 
struct AvatarModel: Hashable, Equatable, Identifiable {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorID: String?
    let dateCreated: Date?
    
    init(
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
    
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }

    var id: String {
        avatarId
    }
    
    static var mock: AvatarModel {
        mocks[0]
    }
    static var mocks: [AvatarModel] {
        let baseDate = Date(timeIntervalSinceReferenceDate: 1_234_567_890)

        return [
            AvatarModel(
                        avatarId: "mock-avatar-1",
                        name: "Alpha",
                        characterOption: .man,
                        characterAction: .smiling,
                        characterLocation: .home,
                        profileImageName: Constants.randomImage,
                        authorID: "mock-author-1",
                        dateCreated: baseDate
                    ),
                    AvatarModel(
                        avatarId: "mock-avatar-2",
                        name: "Beta",
                        characterOption: .woman,
                        characterAction: .studying,
                        characterLocation: .school,
                        profileImageName: Constants.randomImage,
                        authorID: "mock-author-2",
                        dateCreated: baseDate.addingTimeInterval(hours: -1)
                    ),
                    AvatarModel(
                        avatarId: "mock-avatar-3",
                        name: "Gamma",
                        characterOption: .alien,
                        characterAction: .fighting,
                        characterLocation: .space,
                        profileImageName: Constants.randomImage,
                        authorID: "mock-author-3",
                        dateCreated: baseDate.addingTimeInterval(hours: -2)
                    ),
            AvatarModel(
                avatarId: "mock-avatar-4",
                name: "Delta",
                characterOption: .cat,
                characterAction: .relaxing,
                characterLocation: .park,
                profileImageName: Constants.randomImage,
                authorID: "mock-author-4",
                dateCreated: baseDate.addingTimeInterval(hours: -3)
            )
        ]
    }
}
