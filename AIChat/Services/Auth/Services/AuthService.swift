//
//  authManager.swift
//  AIChat
//
//  Created by macbook on 24.01.2025.
//
import SwiftUI

enum AuthServiceError: LocalizedError {
    case emailAlreadyInUse
    case invalidCredential
    case invalidEmail
    case network
    case notSignedIn
    case requiresRecentLogin
    case weakPassword
    case wrongPassword
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .invalidCredential:
            return "The email or password is incorrect."
        case .invalidEmail:
            return "Enter a valid email address."
        case .network:
            return "You're offline. Please reconnect and try again."
        case .notSignedIn:
            return "You are no longer signed in."
        case .requiresRecentLogin:
            return "For security reasons, please sign in again before continuing."
        case .weakPassword:
            return "Your password must be at least 6 characters."
        case .wrongPassword:
            return "The email or password is incorrect."
        case .unknown(let message):
            return message
        }
    }
}

protocol AuthService: Sendable {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> 
    func createUser(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func getAuthenticatedUser() -> UserAuthInfo?
    func sendPasswordReset(email: String) async throws
    func signIn(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}
