import Foundation

extension AuthClient {
    public static func mock(user: UserAuthInfo? = nil) -> Self {
        Self(
            addAuthenticatedUserListener: { _ in
                AsyncStream { continuation in
                    continuation.yield(user)
                }
            },
            getAuthenticatedUser: {
                user
            },
            signInAnonymously: {
                (UserAuthInfo.mock(isAnonymous: true), true)
            },
            signInApple: {
                (UserAuthInfo.mock(isAnonymous: false), false)
            },
            signOut: {
            },
            deleteAccount: {
            }
        )
    }

    public static let unimplemented = Self(
        addAuthenticatedUserListener: { _ in
            fatalError("AuthClient.addAuthenticatedUserListener unimplemented")
        },
        getAuthenticatedUser: {
            fatalError("AuthClient.getAuthenticatedUser unimplemented")
        },
        signInAnonymously: {
            fatalError("AuthClient.signInAnonymously unimplemented")
        },
        signInApple: {
            fatalError("AuthClient.signInApple unimplemented")
        },
        signOut: {
            fatalError("AuthClient.signOut unimplemented")
        },
        deleteAccount: {
            fatalError("AuthClient.deleteAccount unimplemented")
        }
    )
}
