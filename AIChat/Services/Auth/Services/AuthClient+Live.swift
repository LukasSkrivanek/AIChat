import AIChatDomain
import Dependencies

extension AuthClient: DependencyKey {
    public static var liveValue: Self {
        let service = FirebaseAuthService()
        return Self(
            addAuthenticatedUserListener: service.addAuthenticatedUserListener,
            getAuthenticatedUser: service.getAuthenticatedUser,
            signInAnonymously: service.signInAnonymously,
            signInApple: service.signInApple,
            signOut: service.signOut,
            deleteAccount: service.deleteAccount
        )
    }

    public static var previewValue: Self {
        .mock()
    }

    public static var testValue: Self {
        .unimplemented
    }
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
