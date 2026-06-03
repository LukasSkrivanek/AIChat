import Foundation

public enum UserServiceError: LocalizedError {
    case network
    case documentNotFound
    case permissionDenied
    case decodingFailed
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .network:
            return "You're offline. Please reconnect and try again."
        case .documentNotFound:
            return "We could not find your account data."
        case .permissionDenied:
            return "You do not have permission to perform this action."
        case .decodingFailed:
            return "We could not read your account data."
        case .unknown(let message):
            return message
        }
    }
}

public struct UserClient: Sendable {
    public var saveUser: @Sendable (UserModel) async throws -> Void
    public var fetchUser: @Sendable (String) async throws -> UserModel?
    public var makeOnboardingCompleted: @Sendable (String, String) async throws -> Void
    public var deleteUser: @Sendable (String) async throws -> Void
    public var streamUser: @Sendable (String) -> AsyncThrowingStream<UserModel, any Error>

    public init(
        saveUser: @escaping @Sendable (UserModel) async throws -> Void,
        fetchUser: @escaping @Sendable (String) async throws -> UserModel?,
        makeOnboardingCompleted: @escaping @Sendable (String, String) async throws -> Void,
        deleteUser: @escaping @Sendable (String) async throws -> Void,
        streamUser: @escaping @Sendable (String) -> AsyncThrowingStream<UserModel, any Error>
    ) {
        self.saveUser = saveUser
        self.fetchUser = fetchUser
        self.makeOnboardingCompleted = makeOnboardingCompleted
        self.deleteUser = deleteUser
        self.streamUser = streamUser
    }
}
