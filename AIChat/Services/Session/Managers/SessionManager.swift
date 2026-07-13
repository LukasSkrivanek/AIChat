//
//  SessionManager.swift
//  AIChat
//

import ComposableArchitecture
import Foundation

struct SessionBootstrap: Equatable, Sendable {
    let didCompleteOnboarding: Bool
    let isNewUser: Bool
}

struct SessionManager {

    @Dependency(\.authManager)
    var authManager
    @Dependency(\.userManager)
    var userManager

    func bootstrap() async throws -> SessionBootstrap {
        if let user = authManager.auth {
            print("User is authenticated: \(user.uId)")
            let currentUser = try await userManager.establishUserSession(auth: user, isNewUser: false)
            return SessionBootstrap(
                didCompleteOnboarding: currentUser.didCompleteOnboarding == true,
                isNewUser: false
            )
        } else {
            let result = try await authManager.signInAnonymously()
            print("Sign in anonymously: \(result.user.uId)")
            let currentUser = try await userManager.establishUserSession(
                auth: result.user,
                isNewUser: result.isNewUser
            )
            return SessionBootstrap(
                didCompleteOnboarding: currentUser.didCompleteOnboarding == true,
                isNewUser: result.isNewUser
            )
        }
    }
}
