//
//  RemoteUserService.swift
//  AIChat
//
//  Created by Codex on 18.05.2026.
//

import Foundation

enum UserServiceError: LocalizedError {
    case network
    case documentNotFound
    case permissionDenied
    case decodingFailed
    case unknown(String)

    var errorDescription: String? {
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

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func fetchUser(userId: String) async throws -> UserModel?
    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws
    func deleteUser(userId: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
}
