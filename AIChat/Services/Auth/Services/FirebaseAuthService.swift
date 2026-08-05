//
//  FirebaseAuthService.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//
import FirebaseAuth
import SwiftUI

struct FirebaseAuthService: AuthService {
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
            onListenerAttached(listener)
        }
        
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        do {
            let result = try await Auth.auth().signInAnonymously()
            return result.asAuthInfo
        } catch {
            throw mapError(error)
        }
    }

    func createUser(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        do {
            let credential = EmailAuthProvider.credential(
                withEmail: email,
                password: password
            )
            if let user = Auth.auth().currentUser, user.isAnonymous {
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            }

            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.asAuthInfo
        } catch {
            throw mapError(error)
        }
    }

    func signIn(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.asAuthInfo
        } catch {
            throw mapError(error)
        }
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapError(error)
        }
    }
    
    func signOut()  throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw mapError(error)
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthServiceError.notSignedIn
        }
        do {
            try await user.delete()
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> AuthServiceError {
        let nsError = error as NSError
        if let authError = AuthErrorCode(rawValue: nsError.code) {
            switch authError {
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .invalidCredential, .userNotFound:
                return .invalidCredential
            case .invalidEmail:
                return .invalidEmail
            case .networkError:
                return .network
            case .requiresRecentLogin:
                return .requiresRecentLogin
            case .wrongPassword:
                return .wrongPassword
            case .weakPassword:
                return .weakPassword
            default:
                return .unknown(nsError.localizedDescription)
            }
        }
        return .unknown(nsError.localizedDescription)
    }
}

extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
}
