//
//  authManager.swift
//  AIChat
//
//  Created by macbook on 24.01.2025.
//
import SwiftUI

enum AuthServiceError: LocalizedError {
    case network
    case notSignedIn
    case requiresRecentLogin
    case unknown(String)

    var errorDescription: String? {
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

protocol AuthService: Sendable {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> 
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}
