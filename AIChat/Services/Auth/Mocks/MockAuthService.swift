//
//  MockauthManager.swift
//  AIChat
//
//  Created by macbook on 24.01.2025.
//
import Foundation

struct MockAuthService: AuthService {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    let currentUser: UserAuthInfo?
    
    init(user: UserAuthInfo? = nil) {
        self.currentUser = user
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        currentUser
    }

    func sendPasswordReset(email: String) async throws {
    }

    func createUser(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(
            uid: currentUser?.uId ?? "mock_email_user",
            email: email,
            isAnonymous: false,
            creationDate: .now,
            lastSignInDate: .now
        )
        return (user, true)
    }

    func signIn(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(
            uid: "mock_signed_in_user",
            email: email,
            isAnonymous: false,
            creationDate: .now,
            lastSignInDate: .now
        )
        return (user, false)
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: true)
        return (user, true)
    }
    
    func signOut() throws {
        
    }
    
    func deleteAccount() async throws {
        
    }

}
