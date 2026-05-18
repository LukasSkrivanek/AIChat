//
//  UserManager.swift
//  AIChat
//
//  Created by macbook on 17.03.2025.
//

import Foundation
import FirebaseFirestore

@Observable
final class UserManager: ObservableObject {

    private let remoteService: RemoteUserService
    private let localService: LocalUserService

    private(set) var currentUser: UserModel?
    
    private var currentUserListener: ListenerRegistration?
    private var currentUserTask: Task<Void, Never>?
    
    init(remoteService: RemoteUserService, localService: LocalUserService) {
        self.remoteService = remoteService
        self.localService = localService
        self.currentUser = localService.getCurrentUser()
        print("Loaded current user: \(currentUser?.userId)")
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? "1.0" : ""
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await remoteService.saveUser(user: user)
        currentUser = user
        addCurrentUserListener(userId: auth.uId)
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserTask?.cancel()
        currentUser = nil
        saveCurrentUserLocally()
    }
    
    func deleteCurrentUser() async throws {
        let currentUserId = try currentUserId()
        try await remoteService.deleteUser(userId: currentUserId)
        signOut()
    }
    
    func makeOnboardingCompletedCurrentUser(profileColorHex: String ) async throws {
        let uid = try currentUserId()
        try await remoteService.makeOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }

    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await remoteService.makeOnboardingCompleted(userId: userId, profileColorHex: profileColorHex)
    }
    
    private func currentUserId() throws -> String {
        guard let userId = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return userId
    }
    
    private func saveCurrentUserLocally() {
        Task {
            do {
                try localService.saveCurrentUser(currentUser)
                print("Successfully saved current user")
            } catch {
                print("Failed to save current user locally: \(error)")
            }
        }
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
    private func addCurrentUserListener(userId: String) {

        currentUserListener?.remove()
        currentUserTask?.cancel()
        
        currentUserTask = Task { [weak self] in
            guard let self else {
                return
            }
            do {
                for try await value in remoteService.streamUser(userId: userId) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                    print("Successfully attached user listener \(value.userId)")
                }
            } catch {
                print("Failed to stream current user: \(error)")
            }
        }
    }
    
}
