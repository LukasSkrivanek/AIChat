//
//  Untitled.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//
import FirebaseAuth
import SwiftUI
import SignInAppleAsync

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
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = await SignInWithAppleHelper()
        do {
            let response = try await helper.signIn()
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: response.token,
                rawNonce: response.nonce
            )

            if let user = Auth.auth().currentUser, user.isAnonymous {
                do {
                    let result = try await user.link(with: credential)
                    return result.asAuthInfo
                } catch let error as NSError {
                    let authError = AuthErrorCode(rawValue: error.code)
                    switch authError {
                    case .providerAlreadyLinked, .credentialAlreadyInUse:
                        if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                            let result = try await Auth.auth().signIn(with: secondaryCredential)
                            return result.asAuthInfo
                        }
                    default:
                        break
                    }
                    throw mapError(error)
                }
            }

            let result = try await Auth.auth().signIn(with: credential)
            return result.asAuthInfo
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
            case .networkError:
                return .network
            case .requiresRecentLogin:
                return .requiresRecentLogin
            case .userNotFound:
                return .notSignedIn
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
