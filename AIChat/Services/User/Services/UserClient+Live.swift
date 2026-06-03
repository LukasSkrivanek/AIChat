import AIChatDomain
import Dependencies

extension UserClient: DependencyKey {
    public static var liveValue: Self {
        let service = FirebaseUserService()
        return Self(
            saveUser: service.saveUser,
            fetchUser: service.fetchUser,
            makeOnboardingCompleted: service.makeOnboardingCompleted,
            deleteUser: service.deleteUser,
            streamUser: service.streamUser
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
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
