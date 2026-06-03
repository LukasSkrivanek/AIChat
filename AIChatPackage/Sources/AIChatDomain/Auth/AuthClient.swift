import Foundation

public enum AuthServiceError: LocalizedError {
    case network
    case notSignedIn
    case requiresRecentLogin
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .network:
            return "You're offline. Please reconnect and try again."
        case .notSignedIn:
            return "You are no longer signed in."
        case .requiresRecentLogin:
            return "For security reasons, please sign in again before continuing."
        case .unknown(let message):
            return message
        }
    }
}

// Closure-based auth dependency used by reducers, managers, previews, and tests.
public struct AuthClient: Sendable {
    public var addAuthenticatedUserListener: @Sendable (
        _ onListenerAttached: @escaping (any NSObjectProtocol) -> Void
    ) -> AsyncStream<UserAuthInfo?>
    public var getAuthenticatedUser: @Sendable () -> UserAuthInfo?
    public var signInAnonymously: @Sendable () async throws -> (
        user: UserAuthInfo,
        isNewUser: Bool
    )
    public var signInApple: @Sendable () async throws -> (
        user: UserAuthInfo,
        isNewUser: Bool
    )
    public var signOut: @Sendable () throws -> Void
    public var deleteAccount: @Sendable () async throws -> Void

    public init(
        addAuthenticatedUserListener: @escaping @Sendable (
            _ onListenerAttached: @escaping (any NSObjectProtocol) -> Void
        ) -> AsyncStream<UserAuthInfo?>,
        getAuthenticatedUser: @escaping @Sendable () -> UserAuthInfo?,
        signInAnonymously: @escaping @Sendable () async throws -> (
            user: UserAuthInfo,
            isNewUser: Bool
        ),
        signInApple: @escaping @Sendable () async throws -> (
            user: UserAuthInfo,
            isNewUser: Bool
        ),
        signOut: @escaping @Sendable () throws -> Void,
        deleteAccount: @escaping @Sendable () async throws -> Void
    ) {
        self.addAuthenticatedUserListener = addAuthenticatedUserListener
        self.getAuthenticatedUser = getAuthenticatedUser
        self.signInAnonymously = signInAnonymously
        self.signInApple = signInApple
        self.signOut = signOut
        self.deleteAccount = deleteAccount
    }
}
