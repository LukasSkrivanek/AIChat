//
//  MockFileManagerUserPersistence.swift
//  AIChat
//
//  Created by macbook on 18.05.2026.
//

import Foundation

struct MockFileManagerUserPersistence: LocalUserService {
    let currentUser: UserModel?

    init(user: UserModel? = nil) {
        self.currentUser = user
    }

    func getCurrentUser() -> UserModel? {
        currentUser
    }

    func saveCurrentUser(_ user: UserModel?) throws {
    }
}
