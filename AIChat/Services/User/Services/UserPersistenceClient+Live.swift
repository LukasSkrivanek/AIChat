import AIChatDomain
import Dependencies

extension UserPersistenceClient: DependencyKey {
    public static var liveValue: Self {
        let persistence = FileManagerUserPersistence()
        return Self(
            getCurrentUser: persistence.getCurrentUser,
            saveCurrentUser: persistence.saveCurrentUser
        )
    }

    public static var previewValue: Self {
        .mock(user: .mock)
    }

    public static var testValue: Self {
        .unimplemented
    }
}

extension DependencyValues {
    var userPersistenceClient: UserPersistenceClient {
        get { self[UserPersistenceClient.self] }
        set { self[UserPersistenceClient.self] = newValue }
    }
}
