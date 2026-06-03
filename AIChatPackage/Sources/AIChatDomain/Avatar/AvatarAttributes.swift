import Foundation

public enum CharacterOption: String, CaseIterable, Hashable, Equatable {
    case man, woman, alien, dog, cat

    public static var `default`: Self {
        .man
    }

    public var plural: String {
        switch self {
        case .man:
            return "Men"
        case .woman:
            return "Women"
        case .alien:
            return "Aliens"
        case .dog:
            return "Dogs"
        case .cat:
            return "Cats"
        }
    }

    public var startsWithAVowel: Bool {
        switch self {
        case .alien:
            return true
        default:
            return false
        }
    }
}

public enum CharacterAction: String, CaseIterable, Hashable, Equatable {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying

    public static var `default`: Self {
        .smiling
    }
}

public enum CharacterLocation: String, CaseIterable, Hashable, Equatable {
    case home, office, hospital, school, park, restaurant, mall, forest, space

    public static var `default`: Self {
        .park
    }
}

public struct AvatarDescriptionBuilder {
    public let characterOption: CharacterOption
    public let characterAction: CharacterAction
    public let characterLocation: CharacterLocation

    public init(
        characterOption: CharacterOption,
        characterAction: CharacterAction,
        characterLocation: CharacterLocation
    ) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }

    public init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }

    public var characterDescription: String {
        let prefix = characterOption.startsWithAVowel ? "An" : "A"
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the  \(characterLocation.rawValue)"
    }
}
