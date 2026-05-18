//
//  RemoteUserService.swift
//  AIChat
//
//  Created by Codex on 18.05.2026.
//

import Foundation

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws
    func deleteUser(userId: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
}
