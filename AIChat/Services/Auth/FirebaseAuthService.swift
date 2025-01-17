//
//  Untitled.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//
import FirebaseAuth
import SwiftUI
import SignInAppleAsync

struct FirebaseAuthService {
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = await SignInWithAppleHelper()
        let response = try await helper.signIn()
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
        
    }
    
    func signOut()  throws {
        try  Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        try await user.delete()
    }
    enum AuthError: Error {
        case userNotFound
        
        var description: String {
            switch self {
            case .userNotFound:
                return "Current authenticated user not found"
            }
        }
    }
    
} 

extension EnvironmentValues {
    @Entry var authService: FirebaseAuthService = FirebaseAuthService()
}

extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
}
