import AIChatDomain
import Dependencies
import Foundation

struct SessionClient: Sendable {
    var bootstrap: @Sendable () async throws -> SessionBootstrap

    init(
        bootstrap: @escaping @Sendable () async throws -> SessionBootstrap
    ) {
        self.bootstrap = bootstrap
    }
}

extension SessionClient: DependencyKey {
    static var liveValue: Self {
        @Dependency(\.authClient) var authClient
        @Dependency(\.userSessionClient) var userSessionClient

        return Self(
            bootstrap: {
                if let user = authClient.getAuthenticatedUser() {
                    print("User is authenticated: \(user.uId)")
                    let currentUser = try await userSessionClient.establishUserSession(
                        user,
                        false
                    )
                    return SessionBootstrap(
                        didCompleteOnboarding: currentUser.didCompleteOnboarding == true,
                        isNewUser: false
                    )
                } else {
                    let result = try await authClient.signInAnonymously()
                    print("Sign in anonymously: \(result.user.uId)")
                    let currentUser = try await userSessionClient.establishUserSession(
                        result.user,
                        result.isNewUser
                    )
                    return SessionBootstrap(
                        didCompleteOnboarding: currentUser.didCompleteOnboarding == true,
                        isNewUser: result.isNewUser
                    )
                }
            }
        )
    }

    static var testValue: Self {
        .unimplemented
    }

    static var previewValue: Self {
        .mock()
    }
}

extension SessionClient {
    static func mock(
        didCompleteOnboarding: Bool = true,
        isNewUser: Bool = false
    ) -> Self {
        Self(
            bootstrap: {
                SessionBootstrap(
                    didCompleteOnboarding: didCompleteOnboarding,
                    isNewUser: isNewUser
                )
            }
        )
    }

    static let unimplemented = Self(
        bootstrap: {
            fatalError("SessionClient.bootstrap unimplemented")
        }
    )
}

extension DependencyValues {
    var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}
