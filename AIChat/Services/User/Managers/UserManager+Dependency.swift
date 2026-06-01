//
//  UserManager+Dependency.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 01.06.2026.
//

import Dependencies

extension UserManager: DependencyKey {
    static var liveValue: UserManager {
        UserManager(
            remoteService: FirebaseUserService(),
            localService: FileManagerUserPersistence()
        )
    }
}

extension DependencyValues {
    var userManager: UserManager {
        get { self[UserManager.self] }
        set { self[UserManager.self] = newValue }
    }
}
