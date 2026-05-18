//
//  MockUserService.swift
//  AIChat
//
//  Created by Codex on 18.05.2026.
//

import Foundation

struct MockUserService: RemoteUserService {
    let currentUser: UserModel?

    init(user: UserModel? = nil) {
        self.currentUser = user
    }

    func saveUser(user: UserModel) async throws {
    }

    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws {
    }

    func deleteUser(userId: String) async throws {
    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
}
