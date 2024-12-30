//
//  AvatarModel.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//
import Foundation

// imutable struct 
struct AvatarModel: Hashable {
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
    
    static var mock: AvatarModel {
        mocks[0]
    }
    static var mocks: [AvatarModel] {
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
            )
        ]
    }
}
struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ??  .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    var characterDescription: String {
        let prefix = characterOption.startsWithAVowel ? "An" : "A"
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the  \(characterLocation.rawValue)"
           }
    
}
enum CharacterOption: String, CaseIterable {
    case man, woman, alien, dog, cat
    
    static var `default`: Self {
        .man
    }
    
    var startsWithAVowel: Bool {
        switch self {
        case .alien:
            return true
        default :
            return false
        }
    }
}
enum CharacterAction: String {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying
    
    static var `default`: Self {
        .smiling
    }
}
enum CharacterLocation: String {
    case home, office, hospital, school, park, restaurant, mall, forest, space
    
    static var `default`: Self {
        .park
    }
}
