//
//  AuthManager.swift
//  AIChat
//
//  Created by macbook on 17.03.2025.
//

import Foundation

@MainActor
@Observable
class AuthManager {
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    init(service: AuthService) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    func getAuthId() throws -> String {
        guard let uid = auth?.uId else {
            throw AuthError.notSignedIn
        }
        return uid
    }
    private func addAuthListener() {
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.auth = value
                print("Auth listener succes: \(value?.uId ?? "no uuid")")
            }
        }
    }
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInAnonymously()
    }
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInApple()
    }
    func signOut() throws {
        try service.signOut()
        auth = nil
    }
    func deleteAccount() async throws{
    }
}
enum AuthError: LocalizedError{
    case notSignedIn
}
