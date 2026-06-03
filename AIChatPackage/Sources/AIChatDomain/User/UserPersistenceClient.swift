import Foundation

public struct UserPersistenceClient: Sendable {
    public var getCurrentUser: @Sendable () -> UserModel?
    public var saveCurrentUser: @Sendable (UserModel?) throws -> Void

    public init(
        getCurrentUser: @escaping @Sendable () -> UserModel?,
        saveCurrentUser: @escaping @Sendable (UserModel?) throws -> Void
    ) {
        self.getCurrentUser = getCurrentUser
        self.saveCurrentUser = saveCurrentUser
    }
}
