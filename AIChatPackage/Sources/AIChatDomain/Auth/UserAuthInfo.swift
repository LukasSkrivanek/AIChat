import Foundation

public struct UserAuthInfo: Sendable {
    public let uId: String
    public let email: String?
    public let isAnonymous: Bool
    public let creationDate: Date?
    public let lastSignInDate: Date?

    public init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uId = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }

    public static func mock(isAnonymous: Bool = false) -> Self {
        UserAuthInfo(
            uid: "mock_user_123",
            email: "hello@user.com",
            isAnonymous: isAnonymous,
            creationDate: .now,
            lastSignInDate: .now
        )
    }
}
