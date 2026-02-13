//
//  UserManager.swift
//  AIChat
//
//  Created by macbook on 17.03.2025.
//

import Foundation
import Observation

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
}

import FirebaseFirestore
struct FirebaseUserService: UserService {
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
}

@MainActor
@Observable
class UserManager: ObservableObject {
    private let service: UserService
    private(set) var currentUser: UserModel?
    
    init(service: UserService, currentUser: UserModel? = nil) {
        self.service = service
        self.currentUser = nil
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? "1.0" : ""
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
    }
    
}
