import AIChatDomain

extension UserSessionClient {
    static func mock(currentUser: UserModel? = .mock) -> Self {
        let session = MockUserSession(currentUser: currentUser)

        return Self(
            currentUser: {
                await session.getCurrentUser()
            },
            establishUserSession: { auth, isNewUser in
                await session.establishUserSession(
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

    static let unimplemented = Self(
        currentUser: {
            fatalError("UserSessionClient.currentUser unimplemented")
        },
        establishUserSession: { _, _ in
            fatalError("UserSessionClient.establishUserSession unimplemented")
        },
        signOut: {
            fatalError("UserSessionClient.signOut unimplemented")
        },
        deleteCurrentUser: {
            fatalError("UserSessionClient.deleteCurrentUser unimplemented")
        },
        makeOnboardingCompletedCurrentUser: { _ in
            fatalError("UserSessionClient.makeOnboardingCompletedCurrentUser unimplemented")
        }
    )
}

private actor MockUserSession {
    private var currentUser: UserModel?

    init(currentUser: UserModel?) {
        self.currentUser = currentUser
    }

    func getCurrentUser() -> UserModel? {
        currentUser
    }

    func establishUserSession(
        auth: UserAuthInfo,
        isNewUser: Bool
    ) -> UserModel {
        let user = UserModel(
            auth: auth,
            creationVersion: isNewUser ? "1.0" : ""
        )
        currentUser = user
        return user
    }

    func signOut() {
        currentUser = nil
    }

    func deleteCurrentUser() throws {
        guard currentUser != nil else {
            throw UserSessionError.noUserId
        }
        currentUser = nil
    }

    func makeOnboardingCompletedCurrentUser(
        profileColorHex: String
    ) throws {
        guard let currentUser else {
            throw UserSessionError.noUserId
        }
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
    }
}
