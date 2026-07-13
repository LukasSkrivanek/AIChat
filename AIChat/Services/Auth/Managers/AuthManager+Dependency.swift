//
//  AuthManager+Dependency.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 01.06.2026.
//

import Dependencies

extension AuthManager: DependencyKey {
    static var liveValue: AuthManager {
        AuthManager(service: FirebaseAuthService())
    }
}

extension DependencyValues {
    var authManager: AuthManager {
        get { self[AuthManager.self] }
        set { self[AuthManager.self] = newValue }
    }
}
