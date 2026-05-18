//
//  FirebaseUserService.swift
//  AIChat
//
//  Created by Codex on 18.05.2026.
//

import Foundation
import FirebaseFirestore
import SwiftfulFirestore

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

    func fetchUser(userId: String) async throws -> UserModel? {
        let snapshot = try await collection.document(userId).getDocument()
        guard snapshot.exists else {
            return nil
        }
        return try snapshot.data(as: UserModel.self)
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
