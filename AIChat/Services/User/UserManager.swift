//
//  UserManager.swift
//  AIChat
//
//  Created by macbook on 17.03.2025.
//

import Foundation
import FirebaseFirestore
import SwiftfulFirestore

protocol LocalUserService {
    
}

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws
    func deleteUser(userId: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
}

struct FirebaseUserService: RemoteUserService {
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        print("SAVE USER START:", user.userId)
        try collection.document(user.userId).setData(from: user, merge: true)
        print("SAVE USER FINISHED:", user.userId)
        let snapshot = try await collection.document(user.userId).getDocument()
        print("SAVE USER SERVER EXISTS:", snapshot.exists, user.userId)
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }
    
    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        print("ONBOARDING UPDATE START:", userId)
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
        print("ONBOARDING UPDATE FINISHED:", userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}

@Observable
final class UserManager: ObservableObject {

    private let service: RemoteUserService

    private(set) var currentUser: UserModel?
    
    private var currentUserListener: ListenerRegistration?
    private var currentUserTask: Task<Void, Never>?
    
    init(service: RemoteUserService, currentUser: UserModel? = nil) {
        self.service = service
        self.currentUser = nil
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? "1.0" : ""
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
        currentUser = user
        addCurrentUserListener(userId: auth.uId)
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserTask?.cancel()
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        let currentUserId = try currentUserId()
        do {
            try await service.deleteUser(userId: currentUserId)
            signOut()
        } catch {
            print("Failed to delete current user: \(error)")
        }
    }
    
    func makeOnboardingCompletedCurrentUser(profileColorHex: String ) async throws {
        let uid = try currentUserId()
        try await service.makeOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }

    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await service.makeOnboardingCompleted(userId: userId, profileColorHex: profileColorHex)
    }
    
    private func currentUserId() throws -> String {
        guard let userId = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return userId
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
                for try await value in service.streamUser(userId: userId) {
                    self.currentUser = value
                    print("Successfully attached user listener \(value.userId)")
                }
            } catch {
                print("Failed to stream current user: ")
            }
        }
    }
    
}
