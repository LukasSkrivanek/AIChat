import Foundation

extension UserPersistenceClient {
    public static func mock(user: UserModel? = nil) -> Self {
        Self(
            getCurrentUser: {
                user
            },
            saveCurrentUser: { _ in
            }
        )
    }

    public static let unimplemented = Self(
        getCurrentUser: {
            fatalError("UserPersistenceClient.getCurrentUser unimplemented")
        },
        saveCurrentUser: { _ in
            fatalError("UserPersistenceClient.saveCurrentUser unimplemented")
        }
    )
}
