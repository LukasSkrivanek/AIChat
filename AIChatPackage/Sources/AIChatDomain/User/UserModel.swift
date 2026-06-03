import AIChatCommon
import Foundation

public struct UserModel: Codable, Equatable, Sendable {
    public let userId: String
    public let email: String?
    public let isAnonymous: Bool?
    public let creationDate: Date?
    public let lastSignInDate: Date?
    public let didCompleteOnboarding: Bool?
    public let profileColorHex: String?
    public let creationVersion: String?

    public init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        creationVersion: String? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }

    public init(auth: UserAuthInfo, creationVersion: String) {
        self.init(
            userId: auth.uId,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            lastSignInDate: auth.lastSignInDate,
            creationVersion: creationVersion
        )
    }

    public enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationVersion = "creation_version"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
    }

    public static var mock: Self {
        mocks[0]
    }

    public static var mocks: [Self] {
        [
            .init(
                userId: "user_1",
                creationDate: Date(),
                didCompleteOnboarding: true,
                profileColorHex: "#33FF57"
            ),
            .init(
                userId: "user_2",
                creationDate: Date().addingTimeInterval(hours: -1),
                didCompleteOnboarding: false,
                profileColorHex: "#33FF57"
            ),
            .init(
                userId: "user_3",
                creationDate: nil,
                didCompleteOnboarding: nil,
                profileColorHex: nil
            ),
            .init(
                userId: "user_4",
                creationDate: Date().addingTimeInterval(hours: -4),
                didCompleteOnboarding: true,
                profileColorHex: "#3357FF"
            ),
            .init(
                userId: "user_5",
                creationDate: Date().addingTimeInterval(hours: -5),
                didCompleteOnboarding: false,
                profileColorHex: "#F3F315"
            ),
        ]
    }
}
