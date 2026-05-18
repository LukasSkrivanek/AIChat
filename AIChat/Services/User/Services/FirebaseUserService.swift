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
        do {
            try collection.document(user.userId).setData(from: user, merge: true)
        } catch {
            throw mapError(error)
        }
        print("SAVE USER FINISHED:", user.userId)
        let snapshot = try await collection.document(user.userId).getDocument()
        print("SAVE USER SERVER EXISTS:", snapshot.exists, user.userId)
    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }

    func fetchUser(userId: String) async throws -> UserModel? {
        let snapshot: DocumentSnapshot
        do {
            snapshot = try await collection.document(userId).getDocument()
        } catch {
            throw mapError(error)
        }
        guard snapshot.exists else {
            return nil
        }
        do {
            return try snapshot.data(as: UserModel.self)
        } catch {
            throw UserServiceError.decodingFailed
        }
    }

    func makeOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        print("ONBOARDING UPDATE START:", userId)
        do {
            try await collection.document(userId).updateData([
                UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
                UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
            ])
        } catch {
            throw mapError(error)
        }
        print("ONBOARDING UPDATE FINISHED:", userId)
    }

    func deleteUser(userId: String) async throws {
        do {
            try await collection.document(userId).delete()
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> UserServiceError {
        let nsError = error as NSError
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                return .network
            default:
                break
            }
        }

        switch nsError.domain {
        case NSURLErrorDomain:
            return .network

        case FirestoreErrorDomain:
            switch nsError.code {
            case FirestoreErrorCode.notFound.rawValue:
                return .documentNotFound

            case FirestoreErrorCode.permissionDenied.rawValue:
                return .permissionDenied

            case FirestoreErrorCode.unavailable.rawValue,
                FirestoreErrorCode.deadlineExceeded.rawValue:
                return .network

            default:
                return .unknown(nsError.localizedDescription)
            }

        default:
            return .unknown(nsError.localizedDescription)
        }
    }
}
