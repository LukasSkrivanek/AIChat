import Foundation

extension UserClient {
    public static func mock(user: UserModel? = nil) -> Self {
        Self(
            saveUser: { _ in
            },
            fetchUser: { _ in
                user
            },
            makeOnboardingCompleted: { _, _ in
            },
            deleteUser: { _ in
            },
            streamUser: { _ in
                AsyncThrowingStream { continuation in
                    if let user {
                        continuation.yield(user)
                    }
                }
            }
        )
    }

    public static let unimplemented = Self(
        saveUser: { _ in
            fatalError("UserClient.saveUser unimplemented")
        },
        fetchUser: { _ in
            fatalError("UserClient.fetchUser unimplemented")
        },
        makeOnboardingCompleted: { _, _ in
            fatalError("UserClient.makeOnboardingCompleted unimplemented")
        },
        deleteUser: { _ in
            fatalError("UserClient.deleteUser unimplemented")
        },
        streamUser: { _ in
            fatalError("UserClient.streamUser unimplemented")
        }
    )
}
