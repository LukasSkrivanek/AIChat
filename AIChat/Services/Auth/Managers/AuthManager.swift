//
//  AuthManager.swift
//  AIChat
//
//  Created by macbook on 17.03.2025.
//

import Foundation

enum AuthError: LocalizedError {
    case notSignedIn
}

@Observable
final class AuthManager {

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

    func createUser(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.createUser(email: email, password: password)
    }

    func sendPasswordReset(email: String) async throws {
        try await service.sendPasswordReset(email: email)
    }

    func signIn(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signIn(email: email, password: password)
    }

    func signOut() throws {
        try service.signOut()
        auth = nil
    }

    func deleteAccount() async throws {
        try await service.deleteAccount()
        auth = nil
    }
}
