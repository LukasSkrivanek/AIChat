import AIChatDomain
import Dependencies
import Foundation

extension UserSessionClient {
    static func live() -> Self {
        @Dependency(\.userClient) var userClient
        @Dependency(\.userPersistenceClient) var userPersistenceClient

        let session = LiveUserSession(
            userClient: userClient,
            userPersistenceClient: userPersistenceClient
        )

        return Self(
            currentUser: {
                await session.getCurrentUser()
            },
            establishUserSession: { auth, isNewUser in
                try await session.establishUserSession(
                    auth: auth,
                    isNewUser: isNewUser
                )
            },
            signOut: {
                await session.signOut()
            },
            deleteCurrentUser: {
                try await session.deleteCurrentUser()
            },
            makeOnboardingCompletedCurrentUser: { profileColorHex in
                try await session.makeOnboardingCompletedCurrentUser(
                    profileColorHex: profileColorHex
                )
            }
        )
    }
}

private actor LiveUserSession {
    private let userClient: UserClient
    private let userPersistenceClient: UserPersistenceClient

    private var currentUser: UserModel?
    private var currentUserTask: Task<Void, Never>?

    init(
        userClient: UserClient,
        userPersistenceClient: UserPersistenceClient
    ) {
        self.userClient = userClient
        self.userPersistenceClient = userPersistenceClient
        self.currentUser = userPersistenceClient.getCurrentUser()
        print("Loaded current user: \(currentUser?.userId)")
    }

    func getCurrentUser() -> UserModel? {
        currentUser
    }

    func establishUserSession(
        auth: UserAuthInfo,
        isNewUser: Bool
    ) async throws -> UserModel {
        let creationVersion = isNewUser ? "1.0" : ""
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await userClient.saveUser(user)
        let currentUser = try await userClient.fetchUser(auth.uId) ?? user
        self.currentUser = currentUser
        saveCurrentUserLocally()
        addCurrentUserListener(userId: auth.uId)
        return currentUser
    }

    func signOut() {
        currentUserTask?.cancel()
        currentUser = nil
        saveCurrentUserLocally()
    }

    func deleteCurrentUser() async throws {
        let currentUserId = try currentUserId()
        try await userClient.deleteUser(currentUserId)
        signOut()
    }

    func makeOnboardingCompletedCurrentUser(
        profileColorHex: String
    ) async throws {
        let uid = try currentUserId()
        try await userClient.makeOnboardingCompleted(uid, profileColorHex)
        if let currentUser {
            self.currentUser = UserModel(
                userId: currentUser.userId,
                email: currentUser.email,
                isAnonymous: currentUser.isAnonymous,
                creationDate: currentUser.creationDate,
                lastSignInDate: currentUser.lastSignInDate,
                didCompleteOnboarding: true,
                creationVersion: currentUser.creationVersion,
                profileColorHex: profileColorHex
            )
            saveCurrentUserLocally()
        }
    }

    private func currentUserId() throws -> String {
        guard let userId = currentUser?.userId else {
            throw UserSessionError.noUserId
        }
        return userId
    }

    private func saveCurrentUserLocally() {
        do {
            try userPersistenceClient.saveCurrentUser(currentUser)
            print("Successfully saved current user")
        } catch {
            print("Failed to save current user locally: \(error)")
        }
    }

    private func addCurrentUserListener(userId: String) {
        currentUserTask?.cancel()

        let userClient = userClient
        currentUserTask = Task { [weak self] in
            guard let self else {
                return
            }
            do {
                for try await value in userClient.streamUser(userId) {
                    await self.updateCurrentUser(value)
                    print("Successfully attached user listener \(value.userId)")
                }
            } catch {
                print("Failed to stream current user: \(error)")
            }
        }
    }

    private func updateCurrentUser(_ user: UserModel) {
        currentUser = user
        saveCurrentUserLocally()
    }
}
