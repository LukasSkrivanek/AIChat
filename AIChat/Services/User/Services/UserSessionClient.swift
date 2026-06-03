import AIChatDomain
import Dependencies

struct UserSessionClient: Sendable {
    var currentUser: @Sendable () async -> UserModel?
    var establishUserSession: @Sendable (UserAuthInfo, Bool) async throws -> UserModel
    var signOut: @Sendable () async -> Void
    var deleteCurrentUser: @Sendable () async throws -> Void
    var makeOnboardingCompletedCurrentUser: @Sendable (String) async throws -> Void

    init(
        currentUser: @escaping @Sendable () async -> UserModel?,
        establishUserSession: @escaping @Sendable (UserAuthInfo, Bool) async throws -> UserModel,
        signOut: @escaping @Sendable () async -> Void,
        deleteCurrentUser: @escaping @Sendable () async throws -> Void,
        makeOnboardingCompletedCurrentUser: @escaping @Sendable (String) async throws -> Void
    ) {
        self.currentUser = currentUser
        self.establishUserSession = establishUserSession
        self.signOut = signOut
        self.deleteCurrentUser = deleteCurrentUser
        self.makeOnboardingCompletedCurrentUser = makeOnboardingCompletedCurrentUser
    }
}

extension UserSessionClient: DependencyKey {
    static var liveValue: Self {
        .live()
    }

    static var previewValue: Self {
        .mock()
    }

    static var testValue: Self {
        .unimplemented
    }
}

extension DependencyValues {
    var userSessionClient: UserSessionClient {
        get { self[UserSessionClient.self] }
        set { self[UserSessionClient.self] = newValue }
    }
}
