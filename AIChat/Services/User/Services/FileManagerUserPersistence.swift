//
//  FileManagerUserPersistence.swift
//  AIChat
//
//  Created by macbook on 18.05.2026.
//

import Foundation

struct FileManagerUserPersistence: LocalUserService {
    private let userDocumentKey = "current_user"

    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }

    func saveCurrentUser(_ user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
